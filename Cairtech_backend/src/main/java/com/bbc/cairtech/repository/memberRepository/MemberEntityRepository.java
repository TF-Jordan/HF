package com.bbc.cairtech.repository.memberRepository;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.Modifying;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.enums.StatusMember;
import com.bbc.cairtech.model.member.MemberEntity;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface MemberEntityRepository extends R2dbcRepository<MemberEntity, UUID> {

    @Query("SELECT * FROM member_entity WHERE id_bbc = :id")
    Flux<MemberEntity> getAllMemberByBbcId(UUID id);

    @Modifying
    @Query("UPDATE member_entity SET status = :status WHERE id_user = :idUser")
    Mono<Void> updateMemberStatus(UUID idUser, StatusMember status);

    Mono<MemberEntity> findByIdUser(UUID idUser);

}
