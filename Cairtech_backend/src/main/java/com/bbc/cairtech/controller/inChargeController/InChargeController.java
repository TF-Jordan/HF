package com.bbc.cairtech.controller.inChargeController;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bbc.cairtech.model.user.Incharge;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.service.genericServiceCreation.GenericServiceCreation;
import com.bbc.cairtech.service.inChargeService.InChargeService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/inCharge")
@RequiredArgsConstructor
public class InChargeController {

    private final InChargeService service;

    private final GenericServiceCreation genServCreation;

    @GetMapping
    public Flux<Incharge> getAllInCharges() {
        return service.getAllInCharges();
    }

    @PostMapping("/member")
    public Mono<String> createMember(MemberEntityRecord memberEntityRecord) {
        return genServCreation.createMember(memberEntityRecord);
    }

}
