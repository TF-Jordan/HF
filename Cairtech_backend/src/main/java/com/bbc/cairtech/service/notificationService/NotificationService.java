package com.bbc.cairtech.service.notificationService;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.Notification;
import com.bbc.cairtech.record.notificationRecord.NotificationRecord;
import com.bbc.cairtech.repository.notificationRepository.NotificationRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;

    public Flux<Notification> findAll() {
        return repository.findAll();
    }

    public Mono<Notification> findById(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Notification non trouvée")));
    }

    public Flux<Notification> findByRecipient(String recipient) {
        return repository.findByRecipient(recipient);
    }

    public Flux<Notification> findUnreadByRecipient(String recipient) {
        return repository.findByRecipientAndViewed(recipient, false);
    }

    public Mono<Notification> create(NotificationRecord record) {
        Notification notif = Notification.builder()
            .type(record.type())
            .message(record.message())
            .recipient(record.recipient())
            .priority(record.priority() != null ? record.priority() : "NORMAL")
            .viewed(false)
            .channel(record.channel())
            .createdAt(LocalDateTime.now())
            .build();
        return repository.save(notif);
    }

    public Mono<Notification> markAsRead(UUID id) {
        return repository.findById(id)
            .switchIfEmpty(Mono.error(new RuntimeException("Notification non trouvée")))
            .flatMap(existing -> {
                existing.setViewed(true);
                return repository.save(existing);
            });
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
