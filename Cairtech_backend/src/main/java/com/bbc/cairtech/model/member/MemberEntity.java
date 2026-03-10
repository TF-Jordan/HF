package com.bbc.cairtech.model.member;

import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import com.bbc.cairtech.enums.StatusMember;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table("member_entity")
public class MemberEntity {

    @Id
    @Column("id_user")
    private UUID idUser;

    private String firstName;

    private String lastName;

    private String dateOfBirth;

    private String gender;

    private String address;

    private String quarter;

    private String inscriptionDate;

    private StatusMember status;

    private String level;

    private String sector;

    @Column("id_bbc")
    private UUID idBBC;

}
