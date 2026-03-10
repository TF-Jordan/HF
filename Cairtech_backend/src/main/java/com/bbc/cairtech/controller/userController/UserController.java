package com.bbc.cairtech.controller.userController;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

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
        return service.createUser(userRecord)
                .onErrorResume(e -> {
                    if (e.getMessage() != null && e.getMessage().contains("already exists")) {
                        return Mono.error(new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage()));
                    }
                    return Mono.error(new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage()));
                });
    }

    @PostMapping("/login")
    public Mono<String> login(@RequestBody UserRecordLogin userRecord) {
        return service.login(userRecord)
                .onErrorResume(e -> {
                    String msg = e.getMessage() != null ? e.getMessage() : "Login failed";
                    if (msg.contains("erronées") || msg.contains("not found")) {
                        return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Email ou mot de passe incorrect"));
                    }
                    return Mono.error(new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, msg));
                });
    }

}
