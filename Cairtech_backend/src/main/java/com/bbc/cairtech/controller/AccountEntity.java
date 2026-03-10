package com.bbc.cairtech.controller;

import java.time.LocalDateTime;
import java.util.List;

import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor

public class AccountEntity {

    private String type;
    private String period;
    LocalDateTime date;
    private String content;
    private List<String> realisations;
    private List<String> difficulties;


    private String autoExamination;

    



    
}
