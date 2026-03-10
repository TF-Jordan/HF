package com.bbc.cairtech.repository.dashboardRepository;

import java.util.UUID;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import com.bbc.cairtech.model.bibleClub.Dashboard;

public interface DashboardRepository extends R2dbcRepository<Dashboard, UUID> {}
