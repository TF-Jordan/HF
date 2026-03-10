package com.bbc.cairtech.service.adminService;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.BibleClub;
import com.bbc.cairtech.model.member.MemberEntity;
import com.bbc.cairtech.model.user.User;
import com.bbc.cairtech.model.user.UserRole;
import com.bbc.cairtech.record.InchargeRecord.InChargeRecord;
import com.bbc.cairtech.record.bbcRecord.BBCRecord;
import com.bbc.cairtech.record.memberRecord.MemberEntityRecord;
import com.bbc.cairtech.record.userRecord.UserRecord;
import com.bbc.cairtech.repository.bibleClubRepository.BibleClubRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRepository;
import com.bbc.cairtech.repository.userRepository.user.UserRoleRepository;
import com.bbc.cairtech.service.bibleClubService.BibleClubService;
import com.bbc.cairtech.service.genericServiceCreation.GenericServiceCreation;
import com.bbc.cairtech.service.roleService.RoleService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class AdminService {

        private final UserRepository adminRepository;
        private final UserRoleRepository userRoleRepository;
        private final RoleService roleService;
        private final PasswordEncoder passwordEncoder;
        private final GenericServiceCreation genericServiceCreation;
        private final BibleClubService bibleClubService;

        @Value("${spring.admin.email}")
        private String adminEmail;

        @Value("${spring.admin.password}")
        private String password;

        @Value("${spring.admin.phoneNumber}")
        private String phone;

        public Mono<User> findByEmail(String email) {
                return adminRepository.findByEmail(email);
        }

        /**
         * Crée le super admin s'il n'existe pas, puis retourne un JWT token.
         * Si l'admin existe déjà, retourne directement un token avec ses rôles
         * existants.
         */
        public Mono<String> createSuperAdmin() {
                return adminRepository.findByEmail(adminEmail)
                                .flatMap(genericServiceCreation::generateTokenForUser)
                                .switchIfEmpty(Mono.defer(() -> {
                                        User admin = new User();
                                        admin.setEmail(adminEmail);
                                        admin.setPassword(passwordEncoder.encode(password));
                                        admin.setPhoneNumber(phone);
                                        admin.setLastConnectionDate(LocalDateTime.now());
                                        admin.setActive(true);
                                        admin.setStatus("ACTIVE");

                                        return adminRepository.save(admin)
                                                        .flatMap(savedAdmin -> roleService.findRoleByName("SUPER_ADMIN")
                                                                        .flatMap(role -> userRoleRepository.save(
                                                                                        UserRole.builder()
                                                                                                        .id_role(role.getId())
                                                                                                        .id_user(savedAdmin
                                                                                                                        .getId())
                                                                                                        .build())
                                                                                        .then(genericServiceCreation
                                                                                                        .generateTokenForUser(
                                                                                                                        savedAdmin))));
                                }));
        }

        /**
         * Crée un admin à partir du UserRecord, puis retourne un JWT token.
         * Si l'email existe déjà, retourne un token avec ses rôles existants.
         */
        public Mono<String> createAdmin(UserRecord userRecord) {
                return adminRepository.findByEmail(userRecord.email())
                                .flatMap(genericServiceCreation::generateTokenForUser)
                                .switchIfEmpty(Mono.defer(() -> {
                                        User admin = new User();
                                        admin.setEmail(userRecord.email());
                                        admin.setPassword(passwordEncoder.encode(userRecord.password()));
                                        admin.setPhoneNumber(userRecord.phoneNumber());
                                        admin.setLastConnectionDate(LocalDateTime.now());
                                        admin.setActive(true);
                                        admin.setStatus("ACTIVE");

                                        return adminRepository.save(admin)
                                                        .flatMap(savedAdmin -> roleService.findRoleByName("ADMIN")
                                                                        .flatMap(role -> userRoleRepository.save(
                                                                                        new UserRole(role.getId(),
                                                                                                        savedAdmin.getId())))
                                                                        .then(genericServiceCreation
                                                                                        .generateTokenForUser(
                                                                                                        savedAdmin)));
                                }));
        }

        /**
         * Crée un responsable à partir du InchargeRecord, puis retourne un JWT token.
         * Si l'email existe déjà, retourne un token avec ses rôles existants.
         */
        public Mono<String> createInCharge(InChargeRecord inChargeRecord) {
                return genericServiceCreation.createInCharge(inChargeRecord);
        }

        /**
         * Crée un membre à partir du MemberEntityRecord, puis retourne un JWT token.
         * Si l'email existe déjà, retourne un token avec ses rôles existants.
         */

        public Mono<String> createMember(MemberEntityRecord memberRecord) {
                return genericServiceCreation.createMember(memberRecord);
        }

        /**
         * Crée un BBC à partir du bbcRecord, puis retourne un objet bbc.
         * 
         */

        public Mono<String> createBibleClub(BBCRecord bbcRecord) {
                return bibleClubService.createBibleClub(bbcRecord);

        }

        /**
         * Crée un leader
         * 
         */

        public Mono<String> createLeader(String email) {
                return genericServiceCreation.createLeader(email);
        }

}
