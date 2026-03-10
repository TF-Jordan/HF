package com.bbc.cairtech.service.schoolYearService;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.SchoolYear;
import com.bbc.cairtech.record.schoolYear.SchoolYearRecord;
import com.bbc.cairtech.repository.schoolYearRepository.SchoolYearRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class SchoolYearService {

    private final SchoolYearRepository repository;

    public Flux<SchoolYear> findAll() {
        return repository.findAll();
    }

    public Mono<SchoolYear> findById(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Année scolaire non trouvée")));
    }

    public Mono<SchoolYear> findCurrent() {
        return repository.findByIsCurrent(true);
    }

    public Mono<SchoolYear> create(SchoolYearRecord record) {
        SchoolYear sy = SchoolYear.builder()
            .label(record.label())
            .startingDate(record.startingDate())
            .endingDate(record.endingDate())
            .isCurrent(record.isCurrent() != null ? record.isCurrent() : false)
            .status(record.status() != null ? record.status() : "ACTIVE")
            .build();
        return repository.save(sy);
    }

    public Mono<SchoolYear> update(UUID id, SchoolYearRecord record) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Année scolaire non trouvée")))
            .flatMap(existing -> {
                if (record.label() != null) existing.setLabel(record.label());
                if (record.startingDate() != null) existing.setStartingDate(record.startingDate());
                if (record.endingDate() != null) existing.setEndingDate(record.endingDate());
                if (record.isCurrent() != null) existing.setIsCurrent(record.isCurrent());
                if (record.status() != null) existing.setStatus(record.status());
                return repository.save(existing);
            });
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
