package com.bbc.cairtech.controller.dailyVerseController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.bibleClub.DailyVerse;
import com.bbc.cairtech.record.dailyVerseRecord.DailyVerseRecord;
import com.bbc.cairtech.service.dailyVerseService.DailyVerseService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/daily-verse")
@RequiredArgsConstructor
public class DailyVerseController {

    private final DailyVerseService dailyVerseService;

    @GetMapping
    public Flux<DailyVerse> getAll() {
        return dailyVerseService.findAll();
    }

    @GetMapping("/latest")
    public Mono<DailyVerse> getLatest() {
        return dailyVerseService.findLatest();
    }

    @GetMapping("/{id}")
    public Mono<DailyVerse> getById(@PathVariable UUID id) {
        return dailyVerseService.findById(id);
    }

    @PostMapping
    public Mono<DailyVerse> create(@RequestBody DailyVerseRecord record) {
        return dailyVerseService.create(record);
    }

    @PatchMapping("/{id}")
    public Mono<DailyVerse> update(@PathVariable UUID id, @RequestBody DailyVerseRecord record) {
        return dailyVerseService.update(id, record);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return dailyVerseService.delete(id);
    }
}
