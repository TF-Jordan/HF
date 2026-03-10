package com.bbc.cairtech.repository.dailyVerseRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.DailyVerse;
import reactor.core.publisher.Mono;

public interface DailyVerseRepository extends R2dbcRepository<DailyVerse, UUID> {
    Mono<DailyVerse> findTopByOrderByDateDesc();
}
