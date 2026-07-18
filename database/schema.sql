-- TravelCarry AI PostgreSQL Database Schema
-- Target: Supabase / PostgreSQL 15+

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    role VARCHAR(50) NOT NULL DEFAULT 'SENDER', -- TRAVELER, SENDER, ADMIN
    rating NUMERIC(3, 2) DEFAULT 0.00,
    trust_score INT DEFAULT 50, -- Scale 0 to 100
    trust_level VARCHAR(50) DEFAULT 'New User', -- Gold Trusted, Silver, Verified, New User
    completed_deliveries INT DEFAULT 0,
    cancellation_rate NUMERIC(5, 2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, BLOCKED, SUSPENDED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Wallet Table
CREATE TABLE wallet (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Wallet History Table
CREATE TABLE wallet_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallet(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    type VARCHAR(50) NOT NULL, -- DEPOSIT, WITHDRAWAL, EARNING, ESCROW_HOLD, ESCROW_RELEASE, REFUND
    description VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Trips Table
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    traveler_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_city VARCHAR(100) NOT NULL,
    end_city VARCHAR(100) NOT NULL,
    departure_date TIMESTAMP WITH TIME ZONE NOT NULL,
    arrival_date TIMESTAMP WITH TIME ZONE NOT NULL,
    luggage_capacity_kg NUMERIC(6, 2) NOT NULL,
    available_space_kg NUMERIC(6, 2) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL, -- CAR, FLIGHT, TRAIN, BUS
    status VARCHAR(50) NOT NULL DEFAULT 'PLANNED', -- PLANNED, ONGOING, COMPLETED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Parcels Table
CREATE TABLE parcels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    weight_kg NUMERIC(6, 2) NOT NULL,
    width_cm NUMERIC(6, 2),
    height_cm NUMERIC(6, 2),
    depth_cm NUMERIC(6, 2),
    start_city VARCHAR(100) NOT NULL,
    end_city VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL, -- ELECTRONICS, FRAGILE, FOOD, LIQUID, DOCUMENTS, REGULAR
    risk_score INT DEFAULT 0,
    packing_recommendation TEXT,
    priority VARCHAR(50) DEFAULT 'REGULAR', -- REGULAR, EMERGENCY
    image_url VARCHAR(512),
    status VARCHAR(50) NOT NULL DEFAULT 'POSTED', -- POSTED, MATCHED, IN_TRANSIT, DELIVERED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bookings Table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parcel_id UUID NOT NULL REFERENCES parcels(id) ON DELETE RESTRICT UNIQUE,
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE RESTRICT,
    traveler_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    price NUMERIC(10, 2) NOT NULL,
    commission NUMERIC(10, 2) NOT NULL,
    base_price NUMERIC(10, 2) NOT NULL,
    pickup_otp VARCHAR(6),
    delivery_otp VARCHAR(6),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, ACCEPTED, REJECTED, PICKED_UP, DELIVERED, CANCELLED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Tracking Table
CREATE TABLE tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE UNIQUE,
    current_latitude NUMERIC(9, 6),
    current_longitude NUMERIC(9, 6),
    status_description VARCHAR(255),
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    co2_saved_kg NUMERIC(8, 2) DEFAULT 0.00,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    sender_id UUID NOT NULL REFERENCES users(id),
    traveler_id UUID REFERENCES users(id),
    amount NUMERIC(10, 2) NOT NULL,
    platform_fee NUMERIC(10, 2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- PAYMENT, PAYOUT, REFUND
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, COMPLETED, FAILED
    reference_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Ratings Table
CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id),
    reviewee_id UUID NOT NULL REFERENCES users(id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    role VARCHAR(50) NOT NULL, -- TRAVELER, SENDER
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Reviews Table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES ratings(id) ON DELETE CASCADE UNIQUE,
    title VARCHAR(150),
    detailed_feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. OTP Table
CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    otp_code VARCHAR(6) NOT NULL,
    purpose VARCHAR(50) NOT NULL, -- LOGIN, PICKUP, DELIVERY
    is_verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    type VARCHAR(50) DEFAULT 'SYSTEM', -- SYSTEM, CHAT, BOOKING, ALERT
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 13. Chat Table
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    traveler_id UUID NOT NULL REFERENCES users(id),
    sender_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_booking_chat UNIQUE (booking_id)
);

-- 14. Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 15. AI Predictions Table
CREATE TABLE ai_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parcel_id UUID REFERENCES parcels(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    match_confidence_score NUMERIC(5, 2), -- 0.00 to 100.00
    predicted_price_min NUMERIC(10, 2),
    predicted_price_rec NUMERIC(10, 2),
    predicted_price_prem NUMERIC(10, 2),
    trust_score INT,
    fraud_risk_score NUMERIC(5, 2),
    delay_probability NUMERIC(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 16. Activity Logs Table
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(150) NOT NULL,
    ip_address VARCHAR(45),
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 17. Reward Badges Table
CREATE TABLE reward_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_name VARCHAR(100) UNIQUE NOT NULL,
    badge_description VARCHAR(255) NOT NULL,
    icon_url VARCHAR(255),
    criteria TEXT
);

-- 18. User Badges Table (Junction Table)
CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES reward_badges(id) ON DELETE CASCADE,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_badge UNIQUE (user_id, badge_id)
);

-- 19. Carbon Savings Table
CREATE TABLE carbon_savings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    co2_saved_kg NUMERIC(10, 2) DEFAULT 0.00,
    fuel_saved_liters NUMERIC(10, 2) DEFAULT 0.00,
    total_trips_shared INT DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 20. Support Tickets Table
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(50) DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, CRITICAL
    status VARCHAR(50) DEFAULT 'OPEN', -- OPEN, IN_PROGRESS, RESOLVED, CLOSED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 21. Audit Logs Table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    performed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    change_summary TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices for optimization
CREATE INDEX idx_trips_route ON trips(start_city, end_city);
CREATE INDEX idx_trips_date ON trips(departure_date, arrival_date);
CREATE INDEX idx_parcels_route ON parcels(start_city, end_city);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_tracking_booking ON tracking(booking_id);
CREATE INDEX idx_messages_chat ON messages(chat_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
