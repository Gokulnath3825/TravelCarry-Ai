package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.RewardBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RewardBadgeRepository extends JpaRepository<RewardBadge, UUID> {
    Optional<RewardBadge> findByBadgeName(String badgeName);
}
