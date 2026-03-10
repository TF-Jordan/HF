package com.bbc.cairtech.service.inChargeService;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.user.Incharge;
import com.bbc.cairtech.repository.inChargeRepository.InChargeRepository;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;

@Service
@RequiredArgsConstructor
public class InChargeService {

    private final InChargeRepository repository;
    

    public Flux<Incharge> getAllInCharges() {
        return repository.findAll();
    }
}
