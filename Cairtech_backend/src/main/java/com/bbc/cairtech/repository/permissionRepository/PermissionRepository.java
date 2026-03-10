package com.bbc.cairtech.repository.permissionRepository;

import java.util.UUID;

import org.springframework.data.r2dbc.repository.R2dbcRepository;

import com.bbc.cairtech.model.user.Permission;

public interface PermissionRepository extends R2dbcRepository<Permission,UUID> {
    
}
