package com.bbc.cairtech.service.activityTypeService;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.activityReport.ActivityType;
import com.bbc.cairtech.record.activityTypeRecord.ActivityTypeRecord;
import com.bbc.cairtech.repository.activityTypeRepository.ActivityTypeRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class ActivityTypeService {

    private final ActivityTypeRepository repository;

    public Flux<ActivityType> findAll() {
        return repository.findAll();
    }

    public Mono<ActivityType> findById(UUID id) {
        return repository.findById(id);
    }

    public Mono<ActivityType> findByName(String name) {
        return repository.findByName(name);
    }

    public Mono<ActivityType> create(ActivityTypeRecord record) {
        ActivityType type = ActivityType.builder()
            .name(record.name())
            .description(record.description())
            .category(record.category())
            .obligated(record.obligated())
            .frequency(record.frequency())
            .build();
        return repository.save(type);
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
