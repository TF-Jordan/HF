package com.bbc.cairtech.controller.publicationController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.bibleClub.Publication;
import com.bbc.cairtech.record.publicationRecord.PublicationRecord;
import com.bbc.cairtech.service.publicationService.PublicationService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/publication")
@RequiredArgsConstructor
public class PublicationController {

    private final PublicationService publicationService;

    @GetMapping
    public Flux<Publication> getAll() {
        return publicationService.findAll();
    }

    @GetMapping("/{id}")
    public Mono<Publication> getById(@PathVariable UUID id) {
        return publicationService.findById(id);
    }

    @GetMapping("/status/{status}")
    public Flux<Publication> getByStatus(@PathVariable String status) {
        return publicationService.findByStatus(status);
    }

    @GetMapping("/author/{author}")
    public Flux<Publication> getByAuthor(@PathVariable String author) {
        return publicationService.findByAuthor(author);
    }

    @PostMapping
    public Mono<Publication> create(@RequestBody PublicationRecord record) {
        return publicationService.create(record);
    }

    @PatchMapping("/{id}")
    public Mono<Publication> update(@PathVariable UUID id, @RequestBody PublicationRecord record) {
        return publicationService.update(id, record);
    }

    @PatchMapping("/{id}/validate")
    public Mono<Publication> validate(@PathVariable UUID id) {
        return publicationService.validate(id, null);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return publicationService.delete(id);
    }
}
