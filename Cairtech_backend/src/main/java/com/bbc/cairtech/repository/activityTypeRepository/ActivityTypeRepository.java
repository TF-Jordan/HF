package com.bbc.cairtech.repository.activityTypeRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.activityReport.ActivityType;
import reactor.core.publisher.Mono;

public interface ActivityTypeRepository extends R2dbcRepository<ActivityType, UUID> {
    Mono<ActivityType> findByName(String name);
}
