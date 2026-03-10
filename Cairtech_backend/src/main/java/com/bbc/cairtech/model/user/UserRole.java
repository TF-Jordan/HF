package com.bbc.cairtech.model.user;

import java.util.UUID;

import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
@Table("user_role_entity")
public class UserRole {

    @Column("id_role")
    private UUID id_role;

    @Column("id_user")
    private UUID id_user;

}
