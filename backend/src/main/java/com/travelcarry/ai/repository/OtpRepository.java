package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.Otp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface OtpRepository extends JpaRepository<Otp, UUID> {
    Optional<Otp> findByEmailAndOtpCodeAndPurpose(String email, String otpCode, String purpose);
    Optional<Otp> findByPhoneNumberAndOtpCodeAndPurpose(String phoneNumber, String otpCode, String purpose);
}
