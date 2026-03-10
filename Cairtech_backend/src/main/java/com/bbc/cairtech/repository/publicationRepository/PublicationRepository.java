package com.bbc.cairtech.repository.publicationRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.Publication;
import reactor.core.publisher.Flux;

public interface PublicationRepository extends R2dbcRepository<Publication, UUID> {
    Flux<Publication> findByStatus(String status);
    Flux<Publication> findByAuthor(String author);
}
