package com.bbc.cairtech.controller.memberController;

import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;

import com.bbc.cairtech.enums.StatusMember;
import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.service.memberService.MemberEntityService;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequiredArgsConstructor
@RequestMapping("/cairtech/api/member")
public class MemberController {

    private final MemberEntityService memberEntityService;

    @GetMapping("bibleclub/{id}")
    @Operation(summary = "Obtenir tous les membres d'un bbc")

    public Flux<MemberEntity> getAllMemberByBbcId(@PathVariable("id") String id) {

        return memberEntityService.getAllMemberByBbcId(UUID.fromString(id));

    }

    @GetMapping("/{id}")
    @Operation(summary = "get a member using his id")
    public Mono<String> getMemberById(@PathVariable("id") String id) {
        return memberEntityService.getMemberById(UUID.fromString(id));
    }

    @GetMapping()
    @Operation(summary = "Obtenir tous les  membres")
    public Flux<MemberEntity> getAllMembers() {
        return memberEntityService.getAllMembers();
    }

    @PostMapping()
    @Operation(summary = "Ajouter un membre")
    public Mono<String> addMember(@RequestBody MemberEntityRecord memberEntity) {
        System.out.println(memberEntity);
        return memberEntityService.createMember(memberEntity);
    }

    @PatchMapping("/{id}/{status}")
    public Mono<MemberEntity> changeStatus(@PathVariable("id") String id,
            @PathVariable("status") String status) {
        return memberEntityService.changeStatusOfMember(UUID.fromString(id), StatusMember.valueOf(status));

    }

}
