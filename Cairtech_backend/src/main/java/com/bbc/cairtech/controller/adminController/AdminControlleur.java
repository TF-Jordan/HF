package com.bbc.cairtech.controller.adminController;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bbc.cairtech.record.InchargeRecord.InChargeRecord;
import com.bbc.cairtech.record.bbcRecord.BBCRecord;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.record.userRecord.UserRecord;
import com.bbc.cairtech.service.adminService.AdminService;
import com.bbc.cairtech.service.bibleClubService.BibleClubService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/admin")
@RequiredArgsConstructor
public class AdminControlleur {

    private final AdminService adminService;

    private final BibleClubService bbcService;

    @PostMapping("/create-admin")
    public Mono<String> createAdmin(UserRecord userRecord) {
        return adminService.createAdmin(userRecord);
    }

    @PostMapping("/create-InCharge")
    public Mono<String> createInCharge(InChargeRecord userRecord) {
        return adminService.createInCharge(userRecord);
    }

    @PostMapping("/create-bbc")
    public Mono<String> createBBC(BBCRecord bbcRecord) {
        return bbcService.createBibleClub(bbcRecord);
    }

    @PostMapping("/create-member")
    public Mono<String> createMember(MemberEntityRecord member) {
        return adminService.createMember(member);
    }

    @PostMapping("/create-leader")
    public Mono<String> createLeader(String email) {
        return adminService.createLeader(email);
    }

}
