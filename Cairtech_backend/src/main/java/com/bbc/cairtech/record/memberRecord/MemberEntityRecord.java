package com.bbc.cairtech.record.memberRecord;

import com.bbc.cairtech.enums.StatusMember;

public record MemberEntityRecord(String email, String password,
        String phoneNumber, String firstName, String lastName,
        String dateOfBirth, String gender, String address,
        String quarter, String inscriptionDate, String date,
        StatusMember status,
        String level, String sector, String idBBC) {

}
