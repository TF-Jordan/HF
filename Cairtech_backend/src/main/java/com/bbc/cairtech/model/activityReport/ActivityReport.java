package com.bbc.cairtech.model.activityReport;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class ActivityReport {

    private UUID id; 
    private ActivityType type;             
    private String title;
    private String author;
    private String status;

    private String reference;             
    private LocalDateTime reportDate; 
    private LocalDateTime validationDate;     
    
    private String content;               
    private List<String> attachments;    
    private String validateBy;        

    
}
