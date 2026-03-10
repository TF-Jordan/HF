package com.bbc.cairtech.repository.schoolYearRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.SchoolYear;
import reactor.core.publisher.Mono;

public interface SchoolYearRepository extends R2dbcRepository<SchoolYear, UUID> {
    Mono<SchoolYear> findByIsCurrent(Boolean isCurrent);
}
