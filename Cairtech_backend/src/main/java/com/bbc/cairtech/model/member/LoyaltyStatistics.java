package com.bbc.cairtech.model.member;

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
@Table("loyalty_statistics")
public class LoyaltyStatistics {

    @Id
    private UUID id;
    @Column("id_user")
    private UUID idUser;
    @Column("number_presence")
    private Integer numberPresence;
    @Column("number_absences")
    private Integer numberAbsences;
    @Column("number_justified_absences")
    private Integer numberJustifiedAbsences;
    @Column("number_consecutive_absences")
    private Integer numberConsecutiveAbsences;
    @Column("engagement_score")
    private Double engagementScore;
    @Column("attendance_rate")
    private Double attendanceRate;
    @Column("abse_rate")
    private Double abseRate;
    @Column("last_presence")
    private LocalDateTime lastPresence;
    private String status;
}
