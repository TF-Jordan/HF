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
@Table("dashboard")
public class Dashboard {

    @Id
    private UUID id;
    private LocalDateTime date;
    private String period;
    private String indicators;
}
