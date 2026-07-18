package com.travelcarry.ai.repository;

import com.travelcarry.ai.entity.WalletHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface WalletHistoryRepository extends JpaRepository<WalletHistory, UUID> {
    List<WalletHistory> findByWalletIdOrderByCreatedAtDesc(UUID walletId);
}
