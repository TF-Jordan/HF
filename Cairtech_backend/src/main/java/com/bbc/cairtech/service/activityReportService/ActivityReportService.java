package com.bbc.cairtech.service.activityReportService;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.activityReport.ActivityReport;
import com.bbc.cairtech.record.activityReportRecord.ActivityReportRecord;
import com.bbc.cairtech.repository.activityReportRepository.ActivityReportRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class ActivityReportService {

    private final ActivityReportRepository repository;

    public Flux<ActivityReport> findAll() {
        return repository.findAll();
    }

    public Mono<ActivityReport> findById(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Rapport d'activité non trouvé")));
    }

    public Flux<ActivityReport> findByAuthor(String author) {
        return repository.findByAuthor(author);
    }

    public Flux<ActivityReport> findByStatus(String status) {
        return repository.findByStatus(status);
    }

    public Mono<ActivityReport> create(ActivityReportRecord record) {
        ActivityReport report = ActivityReport.builder()
            .type(record.type())
            .title(record.title())
            .author(record.author())
            .status(record.status() != null ? record.status() : "DRAFT")
            .reference(record.reference())
            .reportDate(LocalDateTime.now())
            .content(record.content())
            .attachments(record.attachments())
            .build();
        return repository.save(report);
    }

    public Mono<ActivityReport> validate(UUID id, String validatedBy) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Rapport non trouvé")))
            .flatMap(existing -> {
                existing.setStatus("VALIDATED");
                existing.setValidationDate(LocalDateTime.now());
                existing.setValidateBy(validatedBy);
                return repository.save(existing);
            });
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
