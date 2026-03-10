package com.bbc.cairtech.model.user;

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
@Table("permission_entity")
public class Permission {

    @Id
    private UUID id;
    @Column("id_role")
    private UUID idRole;
    private String action;
    private String ressource;
    private String description;
}
