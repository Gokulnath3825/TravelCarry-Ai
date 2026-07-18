package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.Parcel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ParcelRepository extends JpaRepository<Parcel, UUID> {
    List<Parcel> findBySenderId(UUID senderId);
    List<Parcel> findByStatus(String status);
}
