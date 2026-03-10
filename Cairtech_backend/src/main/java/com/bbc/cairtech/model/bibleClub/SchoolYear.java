package com.bbc.cairtech.model.bibleClub;

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
@Table("school_year")
public class SchoolYear {

    @Id
    private UUID id;
    private String label;
    @Column("starting_date")
    private String startingDate;
    @Column("ending_date")
    private String endingDate;
    @Column("is_current")
    private Boolean isCurrent;
    private String status;
}
