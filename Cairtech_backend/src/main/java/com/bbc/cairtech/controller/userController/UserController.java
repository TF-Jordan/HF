package com.bbc.cairtech.controller.userController;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bbc.cairtech.record.userRecord.UserRecord;
import com.bbc.cairtech.record.userRecord.UserRecordLogin;
import com.bbc.cairtech.service.userService.UserService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService service;

    @PostMapping
    public Mono<String> createUser(@RequestBody UserRecord userRecord) {
        return service.createUser(userRecord);
    }

    @GetMapping("/login")
    public Mono<String> login(UserRecordLogin userRecord) {
        return service.login(userRecord);
    }

}
