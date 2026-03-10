package com.bbc.cairtech.repository.personnalPlanRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.PersonnalPlan;
import reactor.core.publisher.Flux;

public interface PersonnalPlanRepository extends R2dbcRepository<PersonnalPlan, UUID> {
    Flux<PersonnalPlan> findByIdUser(UUID idUser);
}
