package com.bbc.cairtech.repository.personnalAccountRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.member.PersonnalAccountEntity;
import reactor.core.publisher.Mono;

public interface PersonnalAccountRepository extends R2dbcRepository<PersonnalAccountEntity, UUID> {
    Mono<PersonnalAccountEntity> findByIdUser(UUID idUser);
}
