package com.bbc.cairtech.model.bibleClub;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table("daily_verse")
public class DailyVerse {

    @Id
    private UUID id;
    private LocalDateTime date;
    private String reference;
    private String verse;
    private String version;
    private String comment;
    private String author;
}
