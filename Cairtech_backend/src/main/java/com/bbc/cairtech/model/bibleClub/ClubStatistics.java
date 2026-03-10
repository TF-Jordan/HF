package com.bbc.cairtech.model.bibleClub;

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
@Table("club_statistics")
public class ClubStatistics {

    @Id
    private UUID id;
    @Column("id_bible_club")
    private UUID idBibleClub;
    @Column("member_number")
    private Integer memberNumber;
    @Column("active_member_number")
    private Integer activeMemberNumber;
    @Column("unactive_member_number")
    private Integer unactiveMemberNumber;
}
