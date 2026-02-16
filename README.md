# ESP32 Data Monitor (Flutter)

Application Flutter pour monitorer deux ESP32 (gants main gauche/droite),
collecter des series de capteurs, labeliser des gestes et lancer une
traduction locale via un modele TFLite.

## Fonctionnalites

- Connexion WebSocket a un ESP32 (IP configurable, defaut 192.168.4.1).
- Visualisation temps reel des capteurs (flex, IMU, yaw/pitch/roll).
- Collecte de gestes par label (66 points par echantillon).
- Export JSON (copie presse-papiers ou fichier local).
- Traduction manuelle ou automatique via un modele TFLite.

## Prerequis

- Flutter SDK >= 3.5
- Dart SDK >= 3.5
- Deux ESP32 qui emettent les trames binaires attendues.
- Fichiers de modele:
  - `assets/model.tflite`
  - `assets/scaler.json`

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Utilisation rapide

1. Ouvrir l'onglet Monitor ou Traduction.
2. Renseigner l'IP de l'ESP32, puis cliquer sur Connecter.
3. Labelisation: choisir un label, puis Collecter 66 points.
4. Exporter les donnees en JSON si besoin.
5. Traduction: activer Play (manuel) ou Demarrer (auto) pour lancer
   l'inference.

## Structure

- `lib/main.dart`: UI, WebSocket, collecte et inference.
- `assets/model.tflite`: modele de traduction.
- `assets/scaler.json`: normalisation des features.

