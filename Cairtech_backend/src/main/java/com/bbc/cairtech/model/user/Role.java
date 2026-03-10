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
@NoArgsConstructor
@AllArgsConstructor   
@Builder
@Table("role_entity")
public class Role {

    @Id
    @Column("id_role")
    private UUID id;
    private String name;
    private String description;
}
