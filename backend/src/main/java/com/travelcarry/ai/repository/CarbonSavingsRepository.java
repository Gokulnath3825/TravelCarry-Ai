package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.CarbonSavings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CarbonSavingsRepository extends JpaRepository<CarbonSavings, UUID> {
    Optional<CarbonSavings> findByUserId(UUID userId);
}
