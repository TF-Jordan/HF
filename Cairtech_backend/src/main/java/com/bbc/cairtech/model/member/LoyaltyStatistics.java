package com.bbc.cairtech.model.member;

import java.time.LocalDateTime;
import java.util.UUID;

public class LoyaltyStatistics {

    private UUID id;                         
    private Integer numberPresence;   
    private Integer numberAbsences;       
    
    private Integer numberJustifiedAbsences;     
    private Integer numberConsecutiveAbsences;       
    private Double engagementScore;         
    private float attendanceRate;  
    private float abseRate;    
  
    private LocalDateTime lastPresence;   
    private String status; 

    
}
