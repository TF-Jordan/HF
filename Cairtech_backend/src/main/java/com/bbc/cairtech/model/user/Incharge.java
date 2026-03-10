package com.bbc.cairtech.model.user;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Table("incharge")
public class Incharge {

    @Id
    @Column("id_user")
    private UUID idUser;

    private String function;

    private String mandate;

    private LocalDateTime nominationDate;

    private List<String> competences;

}
