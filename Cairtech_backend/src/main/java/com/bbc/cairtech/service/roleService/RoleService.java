package com.bbc.cairtech.service.roleService;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.user.Role;
import com.bbc.cairtech.repository.roleRepository.RoleRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRoleRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class RoleService {

    private final RoleRepository roleRepository;

    private final UserRoleRepository userRoleRepository;

    List<Role> listeOfRole = List.of(
        Role.builder().name("SUPER_ADMIN")
            .description("super administrateur charger de creer les admin")
            .build(),
        Role.builder().name("ADMIN")
            .description("administrateur charger de creer les utilisateurs,responsables,leaders")
            .build(),
        Role.builder().name("LEADER")
            .description("leader d'un groupe au sein du bbc")
            .build(),
        Role.builder().name("PRESIDENT")
            .description( "president d'un groupe au sein du bbc")
            .build()
    );


    public Mono<Boolean> initializeRole() {

        return roleRepository.count()
        .flatMap(count -> {
            if (count == 0) {
                return roleRepository.saveAll(listeOfRole)
                .then(Mono.just(true));
            }
            return Mono.just(false);
        });
        
    }

    public Mono<Role> findRoleByName(String name){
        return roleRepository.findByName(name);
    }

    public Mono<List<String>> getAllRolesByUserId(UUID userId) {
        return userRoleRepository.findByUserId(userId) 
            .flatMap(userRole -> roleRepository.findById(userRole.getId_role())) 
            .map(role -> role.getName()) 
            .collectList(); 
    }

    
}
