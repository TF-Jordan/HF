package com.bbc.cairtech.service.genericServiceCreation;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.bbc.cairtech.mapper.EntityMapper;
import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.model.user.Incharge;
import com.bbc.cairtech.model.user.User;
import com.bbc.cairtech.model.user.UserRole;
import com.bbc.cairtech.record.InchargeRecord.InChargeRecord;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.repository.inChargeRepository.InChargeRepository;
import com.bbc.cairtech.repository.memberRepository.MemberEntityRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRoleRepository;
import com.bbc.cairtech.service.roleService.RoleService;
import com.bbc.cairtech.utils.JwtUtils;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class GenericServiceCreation {

        private final InChargeRepository inChargeRepository;
        private final UserRoleRepository userRoleRepository;
        private final MemberEntityRepository memberEntityRepository;
        private final UserRepository userRepository;
        private final RoleService roleService;
        private final JwtUtils jwtUtils;
        private final PasswordEncoder passwordEncoder;
        private final EntityMapper entityMapper;

        /**
         * Méthode générique JWT token
         *
         */
        public <T> Mono<String> generateTokenForUser(T entity) {
                if (entity instanceof MemberEntity member) {
                        return userRepository.findById(member.getIdUser())
                                        .flatMap(user -> roleService.getAllRolesByUserId(user.getId())
                                                        .map(roles -> jwtUtils.generateMemberToken(user, member,
                                                                        roles)));
                } else if (entity instanceof Incharge incharge) {
                        return userRepository.findById(incharge.getIdUser())
                                        .flatMap(user -> memberEntityRepository.findByIdUser(incharge.getIdUser())
                                                        .flatMap(member -> roleService.getAllRolesByUserId(user.getId())
                                                                        .map(roles -> jwtUtils.generateInchargeToken(
                                                                                        user, member, incharge,
                                                                                        roles))));
                } else if (entity instanceof User user) {
                        return roleService.getAllRolesByUserId(user.getId())
                                        .map(roles -> jwtUtils.generateUserToken(user, roles));
                }
                return Mono.error(new IllegalArgumentException("Type non supporté : " + entity.getClass().getName()));
        }

        /**
         * Crée un responsable (InCharge) :
         * 
         */
        public Mono<String> createInCharge(InChargeRecord inChargeRecord) {
                return userRepository.findByEmail(inChargeRecord.email())
                                .flatMap(this::generateTokenForUser)
                                .switchIfEmpty(Mono.defer(() -> {
                                        User user = entityMapper.toUserFromInCharge(inChargeRecord);
                                        user.setPassword(passwordEncoder.encode(inChargeRecord.password()));
                                        user.setLastConnectionDate(LocalDateTime.now());
                                        user.setActive(true);
                                        user.setStatus("ACTIVE");

                                        return userRepository.save(user)
                                                        .flatMap(savedUser -> {
                                                                MemberEntity member = entityMapper
                                                                                .toMemberEntityFromInCharge(
                                                                                                inChargeRecord);
                                                                member.setIdUser(savedUser.getId());

                                                                Incharge incharge = entityMapper
                                                                                .toIncharge(inChargeRecord);
                                                                incharge.setIdUser(savedUser.getId());

                                                                return memberEntityRepository.save(member)
                                                                                .then(inChargeRepository.save(incharge))
                                                                                .then(roleService.findRoleByName(
                                                                                                "PRESIDENT")
                                                                                                .flatMap(role -> userRoleRepository
                                                                                                                .save(new UserRole(
                                                                                                                                role.getId(),
                                                                                                                                savedUser.getId()))))
                                                                                .then(generateTokenForUser(savedUser));
                                                        });
                                }));
        }

        /**
         * Crée un membre :
         *
         */
        public Mono<String> createMember(MemberEntityRecord userRecord) {
                return userRepository.findByEmail(userRecord.email())
                                .flatMap(this::generateTokenForUser)
                                .switchIfEmpty(Mono.defer(() -> {
                                        User user = entityMapper.toUser(userRecord);
                                        user.setPassword(passwordEncoder.encode(userRecord.password()));
                                        user.setLastConnectionDate(LocalDateTime.now());
                                        user.setActive(true);
                                        user.setStatus("ACTIVE");

                                        return userRepository.save(user)
                                                        .flatMap(savedUser -> {
                                                                MemberEntity member = entityMapper
                                                                                .toMemberEntity(userRecord);
                                                                member.setIdUser(savedUser.getId());

                                                                return memberEntityRepository.save(member)
                                                                                .then(roleService.findRoleByName("USER")
                                                                                                .flatMap(role -> userRoleRepository
                                                                                                                .save(new UserRole(
                                                                                                                                role.getId(),
                                                                                                                                savedUser.getId())))
                                                                                                .then(generateTokenForUser(
                                                                                                                savedUser)));
                                                        });
                                }));
        }

        /**
         * Crée un leader à partir de l'email d'un membre existant.
         * Le User existe déjà dans user_entity, donc la FK est satisfaite.
         */
        public Mono<String> createLeader(String email) {
                return userRepository.findByEmail(email)
                                .switchIfEmpty(Mono.error(
                                                new RuntimeException("User not found for email: " + email)))
                                .flatMap(user -> roleService.findRoleByName("LEADER")
                                                .switchIfEmpty(Mono.error(
                                                                new RuntimeException("Role LEADER not found")))
                                                .flatMap(role -> {
                                                        UserRole userRole = new UserRole(role.getId(), user.getId());
                                                        return userRoleRepository.save(userRole)
                                                                        .then(generateTokenForUser(user));
                                                }));
        }
}
