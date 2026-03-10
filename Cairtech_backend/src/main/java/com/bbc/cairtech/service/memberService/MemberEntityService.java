package com.bbc.cairtech.service.memberService;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.enums.StatusMember;
import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.repository.memberRepository.MemberEntityRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRepository;
import com.bbc.cairtech.service.genericServiceCreation.GenericServiceCreation;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class MemberEntityService {

    private final MemberEntityRepository memberEntityRepository;
    private final UserRepository userRepository;
    private final GenericServiceCreation genCreation;

    public Flux<MemberEntity> getAllMemberByBbcId(UUID id) {
        return memberEntityRepository.getAllMemberByBbcId(id);
    }

    public Mono<String> createMember(MemberEntityRecord memberEntityRecord) {
        return genCreation.createMember(memberEntityRecord);
    }

    /**
     * Récupère un membre par son id_user et génère un token.
     * On cherche le User dans user_entity pour générer le token.
     */
    public Mono<String> getMemberById(UUID idUser) {
        return memberEntityRepository.findById(idUser)
                .switchIfEmpty(Mono.error(new RuntimeException("User not found")))
                .flatMap(genCreation::generateTokenForUser);
    }

    public Flux<MemberEntity> getAllMembers() {
        return memberEntityRepository.findAll();
    }

    
    public Mono<MemberEntity> changeStatusOfMember(UUID idUser, StatusMember status) {
        return memberEntityRepository.findByIdUser(idUser)
                .flatMap(member -> {
                    member.setStatus(status);
                    return memberEntityRepository.save(member);
                });
    }

}
