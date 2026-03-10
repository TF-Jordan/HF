package com.bbc.cairtech.record.InchargeRecord;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.relational.core.mapping.Column;

import com.bbc.cairtech.enums.StatusMember;

public record InChargeRecord(String email, String password,
        String phoneNumber, String firstName, String lastName,
        String dateOfBirth, String gender, String address,
        String quarter, String inscriptionDate, String date,
        StatusMember status,
        String level, String sector, String idBBC,
        String function, String mandate, LocalDateTime nominationDate,
        List<String> competences) {

}
