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
@Table("publication")
public class Publication {

    @Id
    private UUID id;
    private String reference;
    private String type;
    private LocalDateTime date;
    private String title;
    private String content;
    private String author;
    private String status;
    @Column("validation_date")
    private LocalDateTime validationDate;
    private String recipient;
    private String category;
}
