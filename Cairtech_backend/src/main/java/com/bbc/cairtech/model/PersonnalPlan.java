package com.bbc.cairtech.model;

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
@Table("personnal_plan")
public class PersonnalPlan {

    @Id
    private UUID id;
    @Column("id_user")
    private UUID idUser;
    private Integer period;
    @Column("auto_examination")
    private String autoExamination;
    private String type;
    private String content;
    private String realisations;
    private String difficulties;
}
