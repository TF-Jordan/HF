package com.bbc.cairtech.repository.notificationRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.Notification;
import reactor.core.publisher.Flux;

public interface NotificationRepository extends R2dbcRepository<Notification, UUID> {
    Flux<Notification> findByRecipient(String recipient);
    Flux<Notification> findByRecipientAndViewed(String recipient, Boolean viewed);
}
