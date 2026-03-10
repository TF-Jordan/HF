package com.bbc.cairtech.controller.schoolYearController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.bibleClub.SchoolYear;
import com.bbc.cairtech.record.schoolYear.SchoolYearRecord;
import com.bbc.cairtech.service.schoolYearService.SchoolYearService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/school-year")
@RequiredArgsConstructor
public class SchoolYearController {

    private final SchoolYearService schoolYearService;

    @GetMapping
    public Flux<SchoolYear> getAll() {
        return schoolYearService.findAll();
    }

    @GetMapping("/current")
    public Mono<SchoolYear> getCurrent() {
        return schoolYearService.findCurrent();
    }

    @GetMapping("/{id}")
    public Mono<SchoolYear> getById(@PathVariable UUID id) {
        return schoolYearService.findById(id);
    }

    @PostMapping
    public Mono<SchoolYear> create(@RequestBody SchoolYearRecord record) {
        return schoolYearService.create(record);
    }

    @PatchMapping("/{id}")
    public Mono<SchoolYear> update(@PathVariable UUID id, @RequestBody SchoolYearRecord record) {
        return schoolYearService.update(id, record);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return schoolYearService.delete(id);
    }
}
