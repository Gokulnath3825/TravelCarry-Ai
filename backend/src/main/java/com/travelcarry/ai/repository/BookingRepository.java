package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {
    List<Booking> findByTravelerId(UUID travelerId);
    List<Booking> findByParcelSenderId(UUID senderId);
    List<Booking> findByTripId(UUID tripId);
}
