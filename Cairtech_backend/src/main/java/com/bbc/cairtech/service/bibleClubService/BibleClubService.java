package com.bbc.cairtech.service.bibleClubService;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bbc.cairtech.model.bibleClub.BibleClub;
import com.bbc.cairtech.record.bbcRecord.BBCRecord;
import com.bbc.cairtech.repository.bibleClubRepository.BibleClubRepository;
import com.bbc.cairtech.utils.JwtUtils;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class BibleClubService {

    private final BibleClubRepository repository;

    private final JwtUtils jwtUtils;


    public Mono<BibleClub> findBibleClubByCode(String code) {
        return repository.findByCode(code);
    }

    public Mono<BibleClub> findBibleClubById(UUID id) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("BibleClub non trouvé avec l'id : " + id)));
    }

    public Flux<BibleClub> findAllBibleClubs() {
        return repository.findAll();
    }


    /**
     * Crée un BBC à partir du BBCRecord. Si le code existe déjà, retourne le BBC
     * existant.
     */
    public Mono<String> createBibleClub(BBCRecord bbcRecord) {
        return repository.findByCode(bbcRecord.code())
                .map(existingBbc -> jwtUtils.generateBBCToken(existingBbc))

                .switchIfEmpty(Mono.defer(() -> {
                    BibleClub bbc = new BibleClub();
                    bbc.setName(bbcRecord.name());
                    bbc.setCode(bbcRecord.code());
                    bbc.setLocalisation(bbcRecord.localisation());
                    bbc.setCity(bbcRecord.ville());
                    bbc.setSchoolName(bbcRecord.schoolName());
                    bbc.setDateCreation(bbcRecord.dateCreation());
                    bbc.setCapacityMax(bbcRecord.capacityMax());
                    bbc.setStatus(bbcRecord.status());
                    //bbc.setSchoolYear(bbcRecord.schoolYear());

                    return repository.save(bbc)
                            .map(existingBbc -> jwtUtils.generateBBCToken(existingBbc));

                }));
    }


    /** Remplace entièrement un BBC existant avec les données du BBCRecord */
    public Mono<String> updateBibleClub(UUID id, BBCRecord bbcRecord) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("BibleClub non trouvé avec l'id : " + id)))
                .flatMap(existingBbc -> {
                    existingBbc.setName(bbcRecord.name());
                    existingBbc.setCode(bbcRecord.code());
                    existingBbc.setLocalisation(bbcRecord.localisation());
                    existingBbc.setCity(bbcRecord.ville());
                    existingBbc.setSchoolName(bbcRecord.schoolName());
                    existingBbc.setDateCreation(bbcRecord.dateCreation());
                    existingBbc.setCapacityMax(bbcRecord.capacityMax());
                    existingBbc.setStatus(bbcRecord.status());
                    /*existingBbc.setSchoolYear(SchoolYear.builder()
                                                             .label(bbcRecord.schoolYear().label())
                                                             .startingDate(bbcRecord.schoolYear().startingDate())
                                                             .endingDate(bbcRecord.schoolYear().endingDate())
                                                             .isCurrent(bbcRecord.schoolYear().isCurrent())
                                                             .status(bbcRecord.schoolYear().status())
                                                             .build());*/

                    return repository.save(existingBbc)
                          .map(savedBbc -> jwtUtils.generateBBCToken(savedBbc));

                });
    }


    /**
     * Met à jour partiellement un BBC : seuls les champs non-null du record sont
     * appliqués
     */
    public Mono<BibleClub> patchBibleClub(UUID id, BBCRecord bbcRecord) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("BibleClub non trouvé avec l'id : " + id)))
                .flatMap(existingBbc -> {
                    if (bbcRecord.name() != null)
                        existingBbc.setName(bbcRecord.name());
                    if (bbcRecord.code() != null)
                        existingBbc.setCode(bbcRecord.code());
                    if (bbcRecord.localisation() != null)
                        existingBbc.setLocalisation(bbcRecord.localisation());
                    if (bbcRecord.ville() != null)
                        existingBbc.setCity(bbcRecord.ville());
                    if (bbcRecord.schoolName() != null)
                        existingBbc.setSchoolName(bbcRecord.schoolName());
                    if (bbcRecord.dateCreation() != null)
                        existingBbc.setDateCreation(bbcRecord.dateCreation());
                    if (bbcRecord.capacityMax() != null)
                        existingBbc.setCapacityMax(bbcRecord.capacityMax());
                    if (bbcRecord.status() != null)
                        existingBbc.setStatus(bbcRecord.status());
                    /*if (bbcRecord.schoolYear() != null)
                        existingBbc.setSchoolYear(bbcRecord.schoolYear());*/

                    return repository.save(existingBbc);
                });
    }


    /** Supprime un BBC par son ID */
    public Mono<Void> deleteBibleClub(UUID id) {
        return repository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("BibleClub not found for : " + id)))
                .flatMap(repository::delete);
    }
}
