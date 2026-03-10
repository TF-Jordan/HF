package com.bbc.cairtech.service.permissionService;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.user.Permission;
import com.bbc.cairtech.repository.permissionRepository.PermissionRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class PermissionService {

    private final PermissionRepository repository;

    public Flux<Permission> findAll() {
        return repository.findAll();
    }

    public Mono<Permission> findById(UUID id) {
        return repository.findById(id);
    }

    public Mono<Permission> create(Permission permission) {
        return repository.save(permission);
    }

    public Mono<Void> delete(UUID id) {
        return repository.deleteById(id);
    }
}
