package com.bbc.cairtech.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.bbc.cairtech.service.adminService.AdminService;
import com.bbc.cairtech.service.roleService.RoleService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@Component
@RequiredArgsConstructor
public class Initializer implements CommandLineRunner {

    private final RoleService roleService;
    private final AdminService adminService;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("Application démarrée ! Initialisation des données...");
        createSuperAdmin().subscribe(
                token -> System.out.println("Super Admin créé avec succès ! Token: " + token),
                error -> System.err.println("Erreur lors de la création du Super Admin : " + error.getMessage()));
    }

    private Mono<String> createSuperAdmin() {
        return roleService.initializeRole()
                .then(adminService.createSuperAdmin());
    }
}
