package com.bbc.cairtech.controller.activityReportController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.activityReport.ActivityReport;
import com.bbc.cairtech.record.activityReportRecord.ActivityReportRecord;
import com.bbc.cairtech.service.activityReportService.ActivityReportService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/activity-report")
@RequiredArgsConstructor
public class ActivityReportController {

    private final ActivityReportService activityReportService;

    @GetMapping
    public Flux<ActivityReport> getAll() {
        return activityReportService.findAll();
    }

    @GetMapping("/{id}")
    public Mono<ActivityReport> getById(@PathVariable UUID id) {
        return activityReportService.findById(id);
    }

    @GetMapping("/author/{author}")
    public Flux<ActivityReport> getByAuthor(@PathVariable String author) {
        return activityReportService.findByAuthor(author);
    }

    @GetMapping("/status/{status}")
    public Flux<ActivityReport> getByStatus(@PathVariable String status) {
        return activityReportService.findByStatus(status);
    }

    @PostMapping
    public Mono<ActivityReport> create(@RequestBody ActivityReportRecord record) {
        return activityReportService.create(record);
    }

    @PatchMapping("/{id}/validate")
    public Mono<ActivityReport> validate(@PathVariable UUID id, @RequestParam String validatedBy) {
        return activityReportService.validate(id, validatedBy);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return activityReportService.delete(id);
    }
}
