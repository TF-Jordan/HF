package com.bbc.cairtech.service.dailyVerseService;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.DailyVerse;
import com.bbc.cairtech.record.dailyVerseRecord.DailyVerseRecord;
import com.bbc.cairtech.repository.dailyVerseRepository.DailyVerseRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class DailyVerseService {

    private final DailyVerseRepository repository;

    public Flux<DailyVerse> findAll() {
        return repository.findAll();
    }

    public Mono<DailyVerse> findById(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("DailyVerse non trouvé")));
    }

    public Mono<DailyVerse> findLatest() {
        return repository.findTopByOrderByDateDesc();
    }

    public Mono<DailyVerse> create(DailyVerseRecord record) {
        DailyVerse verse = DailyVerse.builder()
            .date(LocalDateTime.now())
            .reference(record.reference())
            .verse(record.verse())
            .version(record.version())
            .comment(record.comment())
            .author(record.author())
            .build();
        return repository.save(verse);
    }

    public Mono<DailyVerse> update(UUID id, DailyVerseRecord record) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("DailyVerse non trouvé")))
            .flatMap(existing -> {
                if (record.reference() != null) existing.setReference(record.reference());
                if (record.verse() != null) existing.setVerse(record.verse());
                if (record.version() != null) existing.setVersion(record.version());
                if (record.comment() != null) existing.setComment(record.comment());
                if (record.author() != null) existing.setAuthor(record.author());
                return repository.save(existing);
            });
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
