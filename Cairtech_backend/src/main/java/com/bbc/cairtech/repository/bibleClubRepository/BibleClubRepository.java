package com.bbc.cairtech.repository.bibleClubRepository;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.bibleClub.BibleClub;

import reactor.core.publisher.Mono;

public interface BibleClubRepository extends R2dbcRepository<BibleClub,UUID>{

    Mono<BibleClub> findByCode(String  code);
    
}
