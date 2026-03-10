package com.bbc.cairtech.controller.notificationController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.bibleClub.Notification;
import com.bbc.cairtech.record.notificationRecord.NotificationRecord;
import com.bbc.cairtech.service.notificationService.NotificationService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/notification")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public Flux<Notification> getAll() {
        return notificationService.findAll();
    }

    @GetMapping("/{id}")
    public Mono<Notification> getById(@PathVariable UUID id) {
        return notificationService.findById(id);
    }

    @GetMapping("/recipient/{recipient}")
    public Flux<Notification> getByRecipient(@PathVariable String recipient) {
        return notificationService.findByRecipient(recipient);
    }

    @GetMapping("/recipient/{recipient}/unread")
    public Flux<Notification> getUnreadByRecipient(@PathVariable String recipient) {
        return notificationService.findUnreadByRecipient(recipient);
    }

    @PostMapping
    public Mono<Notification> create(@RequestBody NotificationRecord record) {
        return notificationService.create(record);
    }

    @PatchMapping("/{id}/read")
    public Mono<Notification> markAsRead(@PathVariable UUID id) {
        return notificationService.markAsRead(id);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return notificationService.delete(id);
    }
}
