package com.bbc.cairtech.mapper;

import java.util.UUID;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.model.user.Incharge;
import com.bbc.cairtech.model.user.User;
import com.bbc.cairtech.record.InchargeRecord.InChargeRecord;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;

@Mapper(componentModel = "spring")
public interface EntityMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "lastConnectionDate", ignore = true)
    @Mapping(target = "active", ignore = true)
    @Mapping(target = "status", ignore = true)
    User toUser(MemberEntityRecord record);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "lastConnectionDate", ignore = true)
    @Mapping(target = "active", ignore = true)
    @Mapping(target = "status", ignore = true)
    User toUserFromInCharge(InChargeRecord record);

    @Mapping(target = "idUser", ignore = true)
    @Mapping(target = "idBBC", source = "idBBC", qualifiedByName = "stringToUuid")
    MemberEntity toMemberEntity(MemberEntityRecord record);

    @Mapping(target = "idUser", ignore = true)
    @Mapping(target = "idBBC", source = "idBBC", qualifiedByName = "stringToUuid")
    MemberEntity toMemberEntityFromInCharge(InChargeRecord record);

    @Mapping(target = "idUser", ignore = true)
    Incharge toIncharge(InChargeRecord record);

    @Named("stringToUuid")
    default UUID stringToUuid(String string) {
        if (string == null || string.isBlank()) {
            return null;
        }
        return UUID.fromString(string);
    }
}
