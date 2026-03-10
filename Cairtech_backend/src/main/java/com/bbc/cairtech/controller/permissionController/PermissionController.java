package com.bbc.cairtech.controller.permissionController;

import java.util.UUID;

import org.springframework.web.bind.annotation.*;

import com.bbc.cairtech.model.user.Permission;
import com.bbc.cairtech.service.permissionService.PermissionService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/cairtech/api/permission")
@RequiredArgsConstructor
public class PermissionController {

    private final PermissionService permissionService;

    @GetMapping
    public Flux<Permission> getAll() {
        return permissionService.findAll();
    }

    @GetMapping("/{id}")
    public Mono<Permission> getById(@PathVariable UUID id) {
        return permissionService.findById(id);
    }

    @PostMapping
    public Mono<Permission> create(@RequestBody Permission permission) {
        return permissionService.create(permission);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable UUID id) {
        return permissionService.delete(id);
    }
}
