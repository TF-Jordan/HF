package com.bbc.cairtech.model.bibleClub;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table("notification")
public class Notification {

    @Id
    private UUID id;
    private String type;
    private String message;
    private String recipient;
    private String priority;
    private Boolean viewed;
    private String channel;
    @Column("created_at")
    private LocalDateTime createdAt;
}
