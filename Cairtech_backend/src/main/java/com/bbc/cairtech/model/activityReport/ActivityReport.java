package com.bbc.cairtech.model.activityReport;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table("activity_report")
public class ActivityReport {

    @Id
    private UUID id;
    private String type;
    private String title;
    private String author;
    private String status;
    private String reference;
    @Column("report_date")
    private LocalDateTime reportDate;
    @Column("validation_date")
    private LocalDateTime validationDate;
    private String content;
    private String attachments;
    @Column("validate_by")
    private String validateBy;
}
