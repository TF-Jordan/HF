package com.bbc.cairtech.controller.activityTypeController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.activityReport.ActivityType;
import com.bbc.cairtech.record.activityTypeRecord.ActivityTypeRecord;
import com.bbc.cairtech.service.activityTypeService.ActivityTypeService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/activity-type")
@RequiredArgsConstructor
public class ActivityTypeController {

    private final ActivityTypeService activityTypeService;

    @GetMapping
    public Flux<ActivityType> getAll() {
        return activityTypeService.findAll();
    }

    @GetMapping("/{id}")
    public Mono<ActivityType> getById(@PathVariable UUID id) {
        return activityTypeService.findById(id);
    }

    @GetMapping("/name/{name}")
    public Mono<ActivityType> getByName(@PathVariable String name) {
        return activityTypeService.findByName(name);
    }

    @PostMapping
    public Mono<ActivityType> create(@RequestBody ActivityTypeRecord record) {
        return activityTypeService.create(record);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return activityTypeService.delete(id);
    }
}
