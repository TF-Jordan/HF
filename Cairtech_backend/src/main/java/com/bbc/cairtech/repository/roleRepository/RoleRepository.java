package com.bbc.cairtech.repository.roleRepository;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.user.Role;

import reactor.core.publisher.Mono;

public interface RoleRepository extends R2dbcRepository<Role, UUID>{

    @Query("SELECT COUNT(*) FROM role_entity;")
    Mono<Long> count();

    Mono<Role> findByName(String name);


    
}
