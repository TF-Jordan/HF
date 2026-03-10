package com.bbc.cairtech.repository.userRepository.user;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.user.User;

import reactor.core.publisher.Mono;

public interface UserRepository extends R2dbcRepository<User, UUID> {
    
    Mono<User> findByEmail(String email);
}
