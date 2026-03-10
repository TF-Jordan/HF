package com.bbc.cairtech.service.publicationService;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.Publication;
import com.bbc.cairtech.record.publicationRecord.PublicationRecord;
import com.bbc.cairtech.repository.publicationRepository.PublicationRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class PublicationService {

    private final PublicationRepository repository;

    public Flux<Publication> findAll() {
        return repository.findAll();
    }

    public Mono<Publication> findById(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Publication non trouvée")));
    }

    public Flux<Publication> findByStatus(String status) {
        return repository.findByStatus(status);
    }

    public Flux<Publication> findByAuthor(String author) {
        return repository.findByAuthor(author);
    }

    public Mono<Publication> create(PublicationRecord record) {
        Publication pub = Publication.builder()
            .reference(record.reference())
            .type(record.type())
            .date(LocalDateTime.now())
            .title(record.title())
            .content(record.content())
            .author(record.author())
            .status(record.status() != null ? record.status() : "DRAFT")
            .recipient(record.recipient())
            .category(record.category())
            .build();
        return repository.save(pub);
    }

    public Mono<Publication> update(UUID id, PublicationRecord record) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Publication non trouvée")))
            .flatMap(existing -> {
                if (record.reference() != null) existing.setReference(record.reference());
                if (record.type() != null) existing.setType(record.type());
                if (record.title() != null) existing.setTitle(record.title());
                if (record.content() != null) existing.setContent(record.content());
                if (record.author() != null) existing.setAuthor(record.author());
                if (record.status() != null) existing.setStatus(record.status());
                if (record.recipient() != null) existing.setRecipient(record.recipient());
                if (record.category() != null) existing.setCategory(record.category());
                return repository.save(existing);
            });
    }

    public Mono<Publication> validate(UUID id, String validatedBy) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Publication non trouvée")))
            .flatMap(existing -> {
                existing.setStatus("VALIDATED");
                existing.setValidationDate(LocalDateTime.now());
                return repository.save(existing);
            });
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
