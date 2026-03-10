package com.bbc.cairtech.model.user;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table("user_entity")
public class User {

    @Id
    @Column("id_user")
    private UUID id;

    private String password;
    private String email;
    private String phoneNumber;
    private LocalDateTime lastConnectionDate;
    private Boolean active;
    private String status;

}
