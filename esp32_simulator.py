#!/usr/bin/env python3
"""
Harmony — Simulateur de gants ESP32.

Serveur WebSocket qui simule les donnees capteur de deux gants (ESP1 / ESP2).
Supporte les deux modes de transmission : JSON et binaire (delta-encoded).

Usage:
    python esp32_simulator.py [--mode json|binary] [--port 81] [--rate 30]

Le client Flutter se connecte a  ws://<IP>:<port>
"""

import argparse
import asyncio
import json
import math
import random
import struct
import time
from enum import Enum

try:
    import websockets
except ImportError:
    print("Dependance manquante : pip install websockets")
    raise SystemExit(1)


# ── Configuration ───────────────────────────────────────────────────────────

SENSOR_COUNT = 14           # 5 flex + 3 accel + 3 gyro + 3 ypr
FULL_MASK    = 0x3FFF       # 14 bits a 1

# Sensor indices (par device)
#  0-4 : flex (Pouce, Index, Majeur, Annulaire, Auriculaire)
#  5-7 : accelerometre (ax, ay, az)
#  8-10: gyroscope (gx, gy, gz)
# 11-13: orientation (yaw, pitch, roll)


class Mode(Enum):
    JSON   = "json"
    BINARY = "binary"


# ── Generateur de donnees realistes ─────────────────────────────────────────

class GloveSim:
    """Simule les capteurs d'un gant avec des mouvements plausibles."""

    def __init__(self, name: str, seed: int = 0):
        self.name = name
        self.rng = random.Random(seed)
        self.t = 0.0

        # Etat courant des 14 capteurs
        self.values = [0] * SENSOR_COUNT

        # Flex sensors : plage typique 0..4095 (ADC 12-bit)
        self.flex_base = [
            self.rng.randint(500, 1500) for _ in range(5)
        ]

        # Frequences et phases aleatoires pour chaque doigt
        self.flex_freq  = [self.rng.uniform(0.3, 1.2) for _ in range(5)]
        self.flex_phase = [self.rng.uniform(0, 2 * math.pi) for _ in range(5)]

        # IMU offsets (gravite sur az ~ 16384 pour +-2g)
        self.accel_offset = [0, 0, 16384]
        self.gyro_offset  = [0, 0, 0]

        # Orientation initiale (yaw, pitch, roll en centiemes de degres)
        self.ypr_base = [
            self.rng.randint(-18000, 18000),
            self.rng.randint(-9000, 9000),
            self.rng.randint(-9000, 9000),
        ]

    def update(self, dt: float):
        """Avance la simulation de `dt` secondes."""
        self.t += dt

        # ── Flex sensors (0..4) ──
        for i in range(5):
            wave = math.sin(2 * math.pi * self.flex_freq[i] * self.t
                            + self.flex_phase[i])
            noise = self.rng.gauss(0, 30)
            self.values[i] = int(
                self.flex_base[i] + 800 * wave + noise
            )
            self.values[i] = max(0, min(4095, self.values[i]))

        # ── Accelerometre (5..7) ──
        for j, off in enumerate(self.accel_offset):
            vibration = self.rng.gauss(0, 200)
            slow_move = 1000 * math.sin(0.5 * self.t + j)
            self.values[5 + j] = int(off + slow_move + vibration)

        # ── Gyroscope (8..10) ──
        for j in range(3):
            drift = 500 * math.sin(0.7 * self.t + j * 1.5)
            noise = self.rng.gauss(0, 100)
            self.values[8 + j] = int(drift + noise)

        # ── Orientation yaw/pitch/roll (11..13) ── centiemes de degres
        for j in range(3):
            swing = int(3000 * math.sin(0.3 * self.t + j * 2.0))
            noise = self.rng.randint(-50, 50)
            self.values[11 + j] = self.ypr_base[j] + swing + noise

    # ── JSON helpers ──

    @property
    def flex(self):
        return self.values[0:5]

    @property
    def imu(self):
        return {
            "ax": self.values[5],
            "ay": self.values[6],
            "az": self.values[7],
            "gx": self.values[8],
            "gy": self.values[9],
            "gz": self.values[10],
        }

    @property
    def ypr(self):
        return {
            "yaw":   self.values[11],
            "pitch": self.values[12],
            "roll":  self.values[13],
        }

    def to_json_dict(self):
        return {
            "flex": self.flex,
            "imu":  self.imu,
            "ypr":  self.ypr,
            "connected": True,
        }


# ── Encodeur binaire ───────────────────────────────────────────────────────

class BinaryEncoder:
    """Encode les frames au format binaire delta du protocole ESP32.

    Format (little-endian) :
        [timestamp 4B uint32][bitmask 4B uint32][deltas int16...]

    Bitmask :
        bits  0..13 → ESP1 (14 capteurs)
        bits 14..27 → ESP2 (14 capteurs)

    Premiere frame : full (tous les bits a 1, valeurs absolues).
    Frames suivantes : delta (seuls les capteurs modifies sont envoyes).
    """

    def __init__(self):
        self.prev_esp1 = None
        self.prev_esp2 = None
        self.start_ms = int(time.time() * 1000)

    def encode(self, esp1_values: list[int], esp2_values: list[int],
               force_full: bool = False) -> bytes:
        now_ms = int(time.time() * 1000) - self.start_ms

        if self.prev_esp1 is None or force_full:
            # Premiere frame : envoi complet
            mask1 = FULL_MASK
            mask2 = FULL_MASK
            deltas1 = list(esp1_values)
            deltas2 = list(esp2_values)
            self.prev_esp1 = list(esp1_values)
            self.prev_esp2 = list(esp2_values)
        else:
            # Frames suivantes : delta
            mask1, deltas1 = self._compute_delta(self.prev_esp1, esp1_values)
            mask2, deltas2 = self._compute_delta(self.prev_esp2, esp2_values)
            self.prev_esp1 = list(esp1_values)
            self.prev_esp2 = list(esp2_values)

        combined_mask = mask1 | (mask2 << SENSOR_COUNT)

        # Header : timestamp(4) + mask(4)
        header = struct.pack("<II", now_ms & 0xFFFFFFFF, combined_mask)

        # Deltas : int16 pour chaque capteur change
        payload = b""
        for v in deltas1:
            payload += struct.pack("<h", max(-32768, min(32767, v)))
        for v in deltas2:
            payload += struct.pack("<h", max(-32768, min(32767, v)))

        return header + payload

    @staticmethod
    def _compute_delta(prev: list[int], curr: list[int]):
        mask = 0
        deltas = []
        for i in range(SENSOR_COUNT):
            diff = curr[i] - prev[i]
            if diff != 0:
                mask |= (1 << i)
                deltas.append(diff)
        return mask, deltas


# ── Presets de gestes ──────────────────────────────────────────────────────

class GesturePreset:
    """Simule un geste specifique en modifiant les parametres des gants."""

    PRESETS = {
        "repos": {
            "description": "Main ouverte, au repos",
            "flex_targets": [500, 500, 500, 500, 500],
        },
        "poing": {
            "description": "Poing ferme",
            "flex_targets": [3500, 3500, 3500, 3500, 3500],
        },
        "pointer": {
            "description": "Index tendu, autres replies",
            "flex_targets": [3000, 500, 3500, 3500, 3500],
        },
        "peace": {
            "description": "Signe de paix (index + majeur)",
            "flex_targets": [3000, 500, 500, 3500, 3500],
        },
        "pouce": {
            "description": "Pouce leve",
            "flex_targets": [500, 3500, 3500, 3500, 3500],
        },
        "wave": {
            "description": "Vague animee (mouvement sinusoidal)",
            "flex_targets": None,  # Gere dynamiquement
        },
    }

    def __init__(self):
        self.current = "repos"
        self.transition_speed = 3.0  # vitesse de transition

    def set_gesture(self, name: str):
        if name in self.PRESETS:
            self.current = name

    def apply(self, glove: GloveSim, dt: float):
        preset = self.PRESETS.get(self.current)
        if not preset:
            return

        targets = preset["flex_targets"]

        if self.current == "wave":
            # Vague dynamique
            for i in range(5):
                phase = glove.t * 3.0 + i * 0.8
                targets_i = int(500 + 2500 * (0.5 + 0.5 * math.sin(phase)))
                glove.flex_base[i] += (targets_i - glove.flex_base[i]) * dt * 5
        elif targets:
            for i in range(5):
                diff = targets[i] - glove.flex_base[i]
                glove.flex_base[i] += diff * dt * self.transition_speed


# ── Serveur WebSocket ──────────────────────────────────────────────────────

clients: set = set()

# Gants simules
left_glove  = GloveSim("Main Gauche", seed=42)
right_glove = GloveSim("Main Droite", seed=99)
encoder     = BinaryEncoder()
gesture     = GesturePreset()


async def handle_client(websocket):
    """Gere un client WebSocket connecte."""
    global clients
    addr = websocket.remote_address
    print(f"[+] Client connecte : {addr}")
    clients.add(websocket)

    try:
        async for message in websocket:
            # Commandes du client (optionnel)
            msg = message.strip().lower() if isinstance(message, str) else ""
            if msg in GesturePreset.PRESETS:
                gesture.set_gesture(msg)
                print(f"    Geste → {msg}")
                await websocket.send(json.dumps({
                    "status": "ok",
                    "gesture": msg,
                    "description": GesturePreset.PRESETS[msg]["description"],
                }))
            elif msg == "list":
                await websocket.send(json.dumps({
                    "presets": list(GesturePreset.PRESETS.keys()),
                }))
    except websockets.ConnectionClosed:
        pass
    finally:
        clients.discard(websocket)
        print(f"[-] Client deconnecte : {addr}")


async def broadcast_loop(mode: Mode, rate: int):
    """Boucle d'envoi des frames a tous les clients connectes."""
    global clients
    dt = 1.0 / rate
    frame_count = 0
    first_frame = True

    print(f"\n{'='*50}")
    print(f"  Harmony ESP32 Simulator")
    print(f"  Mode: {mode.value.upper()} | Rate: {rate} Hz")
    print(f"{'='*50}")
    print(f"  Gestes disponibles (envoyez le nom en texte) :")
    for name, info in GesturePreset.PRESETS.items():
        print(f"    {name:12s} — {info['description']}")
    print(f"{'='*50}\n")

    while True:
        await asyncio.sleep(dt)

        # Mise a jour de la simulation
        gesture.apply(left_glove, dt)
        gesture.apply(right_glove, dt)
        left_glove.update(dt)
        right_glove.update(dt)

        if not clients:
            first_frame = True
            continue

        frame_count += 1

        # Construction de la frame
        if mode == Mode.JSON:
            payload = json.dumps({
                "esp1": left_glove.to_json_dict(),
                "esp2": right_glove.to_json_dict(),
            })
        else:
            payload = encoder.encode(
                left_glove.values,
                right_glove.values,
                force_full=first_frame,
            )
            first_frame = False

        # Envoi a tous les clients
        dead = set()
        for ws in clients:
            try:
                await ws.send(payload)
            except websockets.ConnectionClosed:
                dead.add(ws)
        clients -= dead

        # Log periodique
        if frame_count % (rate * 5) == 0:
            flex_str = " ".join(f"{v:4d}" for v in left_glove.flex)
            print(f"  [frame {frame_count:6d}] "
                  f"Flex L: [{flex_str}] | "
                  f"Geste: {gesture.current} | "
                  f"Clients: {len(clients)}")


async def main(host: str, port: int, mode: Mode, rate: int):
    """Point d'entree du serveur."""
    print(f"\n  Demarrage du serveur sur ws://{host}:{port}")
    print(f"  Dans l'app Flutter, configurez : IP={host}  Port={port}\n")

    async with websockets.serve(handle_client, host, port):
        await broadcast_loop(mode, rate)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Harmony — Simulateur ESP32 pour gants de capture gestuelle"
    )
    parser.add_argument(
        "--host", default="0.0.0.0",
        help="Adresse d'ecoute (defaut: 0.0.0.0)"
    )
    parser.add_argument(
        "--port", type=int, default=81,
        help="Port WebSocket (defaut: 81)"
    )
    parser.add_argument(
        "--mode", choices=["json", "binary"], default="json",
        help="Mode de transmission (defaut: json)"
    )
    parser.add_argument(
        "--rate", type=int, default=30,
        help="Frequence d'envoi en Hz (defaut: 30)"
    )
    args = parser.parse_args()

    try:
        asyncio.run(main(args.host, args.port, Mode(args.mode), args.rate))
    except KeyboardInterrupt:
        print("\n  Serveur arrete.")
