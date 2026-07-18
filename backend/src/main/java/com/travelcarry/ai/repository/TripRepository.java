package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TripRepository extends JpaRepository<Trip, UUID> {
    List<Trip> findByTravelerId(UUID travelerId);
    List<Trip> findByStartCityAndEndCityAndStatus(String startCity, String endCity, String status);
    List<Trip> findByStatus(String status);
}
