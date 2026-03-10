package com.bbc.cairtech.model.activityReport;

import java.util.UUID;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table("activity_type")
public class ActivityType {

    @Id
    private UUID id;
    private String name;
    private String description;
    private String category;
    private Boolean obligated;
    private Integer frequency;
}
