package com.bbc.cairtech.controller.bibleClubController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.bibleClub.BibleClub;
import com.bbc.cairtech.record.bbcRecord.BBCRecord;
import com.bbc.cairtech.service.bibleClubService.BibleClubService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/bbc")
@RequiredArgsConstructor
public class BibleClubController {

    private final BibleClubService bibleClubService;

    @GetMapping
    public Flux<BibleClub> getAllBibleClubs() {
        return bibleClubService.findAllBibleClubs();
    }

    @GetMapping("/{id}")
    public Mono<BibleClub> getBibleClubById(@PathVariable UUID id) {
        return bibleClubService.findBibleClubById(id);
    }

    @GetMapping("/code/{code}")
    public Mono<BibleClub> getBibleClubByCode(@PathVariable String code) {
        return bibleClubService.findBibleClubByCode(code);
    }

    @PostMapping
    public Mono<String> createBibleClub(@RequestBody BBCRecord bbcRecord) {
        return bibleClubService.createBibleClub(bbcRecord);
    }

    @PutMapping("/{id}")
    public Mono<String> updateBibleClub(@PathVariable UUID id, @RequestBody BBCRecord bbcRecord) {
        return bibleClubService.updateBibleClub(id, bbcRecord);
    }

    @PatchMapping("/{id}")
    public Mono<BibleClub> patchBibleClub(@PathVariable UUID id, @RequestBody BBCRecord bbcRecord) {
        return bibleClubService.patchBibleClub(id, bbcRecord);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> deleteBibleClub(@PathVariable UUID id) {
        return bibleClubService.deleteBibleClub(id);
    }
}
