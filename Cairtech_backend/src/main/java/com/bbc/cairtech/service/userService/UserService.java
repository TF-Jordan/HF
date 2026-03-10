package com.bbc.cairtech.service.userService;

import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.user.User;
import com.bbc.cairtech.record.userRecord.UserRecord;
import com.bbc.cairtech.record.userRecord.UserRecordLogin;
import com.bbc.cairtech.repository.userRepository.user.UserRepository;
import com.bbc.cairtech.service.genericServiceCreation.GenericServiceCreation;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Mono;

@RequiredArgsConstructor
@Service
public class UserService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UserRepository repository;

    private final GenericServiceCreation genService;

    /*
     * Connexion d'un utilisateur
     */

    public Mono<String> login(UserRecordLogin userRecordLogin) {
        return repository.findByEmail(userRecordLogin.email())
                .flatMap(user -> {

                    if (passwordEncoder.matches(userRecordLogin.password(), user.getPassword())) {
                        return genService.generateTokenForUser(user);
                    } else {
                        return Mono.error(new RuntimeException("Informations erronées"));
                    }
                })
                .switchIfEmpty(Mono.error(new RuntimeException("User not found")));
    }

    public Mono<String> createUser(UserRecord userRecord) {
        return repository.findByEmail(userRecord.email())
                .flatMap(user -> Mono.<String>error(new RuntimeException("User already exists")))
                .switchIfEmpty(Mono.defer(() -> {
                    User user = new User();
                    user.setEmail(userRecord.email());
                    user.setPassword(passwordEncoder.encode(userRecord.password()));
                    user.setPhoneNumber(userRecord.phoneNumber());
                    user.setLastConnectionDate(LocalDateTime.now());
                    user.setActive(true);
                    user.setStatus("ACTIVE");
                    return repository.save(user)
                            .flatMap(savedUser -> genService.generateTokenForUser(savedUser));
                }));
    }

}
