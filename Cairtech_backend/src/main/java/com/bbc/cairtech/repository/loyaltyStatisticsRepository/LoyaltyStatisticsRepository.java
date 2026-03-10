package com.bbc.cairtech.repository.loyaltyStatisticsRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.member.LoyaltyStatistics;
import reactor.core.publisher.Mono;

public interface LoyaltyStatisticsRepository extends R2dbcRepository<LoyaltyStatistics, UUID> {
    Mono<LoyaltyStatistics> findByIdUser(UUID idUser);
}
