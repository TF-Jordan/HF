package com.bbc.cairtech.model.bibleClub;

import java.util.UUID;

import org.springframework.data.annotation.Id;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class SchoolYear {
    @Id
    private UUID id;
    private String label;
    private String startingDate;
    private String endingDate;
    private Boolean isCurrent;
    private String status;
}
