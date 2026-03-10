package com.bbc.cairtech.repository.activityReportRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.activityReport.ActivityReport;
import reactor.core.publisher.Flux;

public interface ActivityReportRepository extends R2dbcRepository<ActivityReport, UUID> {
    Flux<ActivityReport> findByAuthor(String author);
    Flux<ActivityReport> findByStatus(String status);
}
