package com.bbc.cairtech.repository.userRepository.user;

import java.util.UUID;

import org.apache.commons.lang3.ObjectUtils.Null;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.user.UserRole;

import reactor.core.publisher.Flux;

public interface UserRoleRepository extends R2dbcRepository<UserRole, Null> {

    @Query("SELECT * FROM user_role_entity WHERE id_user = :userId")
    Flux<UserRole> findByUserId(UUID userId);

}
