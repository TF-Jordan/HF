package com.bbc.cairtech.repository.inChargeRepository;

import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.user.Incharge;

import reactor.core.publisher.Mono;

import java.util.UUID;

public interface InChargeRepository extends R2dbcRepository<Incharge, UUID> {

    Mono<Incharge> findByIdUser(UUID idUser);
}
