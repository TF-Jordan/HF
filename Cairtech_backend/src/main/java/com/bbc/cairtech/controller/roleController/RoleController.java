package com.bbc.cairtech.controller.roleController;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.user.Role;
import com.bbc.cairtech.service.roleService.RoleService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/role")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    @PostMapping("/init")
    public Mono<Boolean> initializeRoles() {
        return roleService.initializeRole();
    }

    @GetMapping("/name/{name}")
    public Mono<Role> getRoleByName(@PathVariable String name) {
        return roleService.findRoleByName(name);
    }

    @GetMapping("/user/{userId}")
    public Mono<List<String>> getRolesByUserId(@PathVariable UUID userId) {
        return roleService.getAllRolesByUserId(userId);
    }
}
