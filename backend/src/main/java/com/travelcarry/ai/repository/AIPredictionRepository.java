package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.AIPrediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AIPredictionRepository extends JpaRepository<AIPrediction, UUID> {
    List<AIPrediction> findByParcelId(UUID parcelId);
    List<AIPrediction> findByTripId(UUID tripId);
}
