package com.bbc.cairtech.repository.clubStatisticsRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.ClubStatistics;
import reactor.core.publisher.Mono;

public interface ClubStatisticsRepository extends R2dbcRepository<ClubStatistics, UUID> {
    Mono<ClubStatistics> findByIdBibleClub(UUID idBibleClub);
}
