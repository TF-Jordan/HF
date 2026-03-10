package com.bbc.cairtech.model.bibleClub;

import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@Data
@RequiredArgsConstructor
@Table("bible_club")
public class BibleClub {

    @Id
    @Column("id_bible_club")
    private UUID id;

    private String name;
    private String code;
    private String localisation;
    private String city;
    private String schoolName;
    private String dateCreation;
    private String schoolLevel;
    private Integer capacityMax;
    private String status;

    @Transient
    private SchoolYear schoolYear;

}
