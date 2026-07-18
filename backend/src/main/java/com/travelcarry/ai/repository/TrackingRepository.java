package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.Tracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface TrackingRepository extends JpaRepository<Tracking, UUID> {
    Optional<Tracking> findByBookingId(UUID bookingId);
}
