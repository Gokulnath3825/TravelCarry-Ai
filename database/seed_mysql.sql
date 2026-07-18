-- TravelCarry AI MySQL Seed Data

-- Clear existing data (order matters due to foreign keys)
DELETE FROM user_badges;
DELETE FROM reward_badges;
DELETE FROM carbon_savings;
DELETE FROM wallet_history;
DELETE FROM wallet;
DELETE FROM trips;
DELETE FROM parcels;
DELETE FROM users;

-- 1. Create Users
-- Admin User
INSERT INTO users (id, email, password_hash, first_name, last_name, phone_number, role, trust_score, trust_level, status)
VALUES (
    UUID_TO_BIN('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    'admin@travelcarry.ai',
    '$2a$10$8.UnVuG9HHgOpTy.Cj9p4O26V.VjJ6J8zC4B1d026i7f2kG.qC0oO', -- bcrypt hash for 'Admin@123'
    'TravelCarry',
    'Admin',
    '+919999999999',
    'ADMIN',
    100,
    'Gold Trusted',
    'ACTIVE'
);

-- Travelers
INSERT INTO users (id, email, password_hash, first_name, last_name, phone_number, role, rating, trust_score, trust_level, completed_deliveries, status)
VALUES 
(
    UUID_TO_BIN('00000000-0000-0000-0000-000000000001'),
    'rohan.sharma@travelcarry.ai',
    '$2a$10$xWwUq3hApt1g3xP9Z98j4O1qA04aXhX.L9V9Z9.C9b9w9E9f9g9h.', -- bcrypt for password123
    'Rohan',
    'Sharma',
    '+919876543210',
    'TRAVELER',
    4.90,
    98,
    'Gold Trusted',
    45,
    'ACTIVE'
),
(
    UUID_TO_BIN('00000000-0000-0000-0000-000000000002'),
    'priya.patel@travelcarry.ai',
    '$2a$10$xWwUq3hApt1g3xP9Z98j4O1qA04aXhX.L9V9Z9.C9b9w9E9f9g9h.',
    'Priya',
    'Patel',
    '+919876543211',
    'TRAVELER',
    4.70,
    88,
    'Silver',
    18,
    'ACTIVE'
),
(
    UUID_TO_BIN('00000000-0000-0000-0000-000000000003'),
    'amit.singh@travelcarry.ai',
    '$2a$10$xWwUq3hApt1g3xP9Z98j4O1qA04aXhX.L9V9Z9.C9b9w9E9f9g9h.',
    'Amit',
    'Singh',
    '+919876543212',
    'TRAVELER',
    4.20,
    75,
    'Verified',
    5,
    'ACTIVE'
);

-- Senders
INSERT INTO users (id, email, password_hash, first_name, last_name, phone_number, role, rating, trust_score, trust_level, completed_deliveries, status)
VALUES 
(
    UUID_TO_BIN('10000000-0000-0000-0000-000000000001'),
    'sneha.rao@travelcarry.ai',
    '$2a$10$xWwUq3hApt1g3xP9Z98j4O1qA04aXhX.L9V9Z9.C9b9w9E9f9g9h.',
    'Sneha',
    'Rao',
    '+918765432100',
    'SENDER',
    4.80,
    95,
    'Gold Trusted',
    12,
    'ACTIVE'
),
(
    UUID_TO_BIN('10000000-0000-0000-0000-000000000002'),
    'vikram.malhotra@travelcarry.ai',
    '$2a$10$xWwUq3hApt1g3xP9Z98j4O1qA04aXhX.L9V9Z9.C9b9w9E9f9g9h.',
    'Vikram',
    'Malhotra',
    '+918765432101',
    'SENDER',
    3.90,
    65,
    'Verified',
    2,
    'ACTIVE'
);

-- 2. Wallets for Users
INSERT INTO wallet (id, user_id, balance, currency) VALUES
(UUID_TO_BIN('e0000000-0000-0000-0000-000000000001'), UUID_TO_BIN('00000000-0000-0000-0000-000000000001'), 5450.00, 'INR'),
(UUID_TO_BIN('e0000000-0000-0000-0000-000000000002'), UUID_TO_BIN('00000000-0000-0000-0000-000000000002'), 2100.00, 'INR'),
(UUID_TO_BIN('e0000000-0000-0000-0000-000000000003'), UUID_TO_BIN('00000000-0000-0000-0000-000000000003'), 450.00, 'INR'),
(UUID_TO_BIN('e0000000-0000-0000-0000-000000000004'), UUID_TO_BIN('10000000-0000-0000-0000-000000000001'), 12500.00, 'INR'),
(UUID_TO_BIN('e0000000-0000-0000-0000-000000000005'), UUID_TO_BIN('10000000-0000-0000-0000-000000000002'), 1500.00, 'INR');

-- 3. Reward Badges
INSERT INTO reward_badges (id, badge_name, badge_description, icon_url, criteria) VALUES
(UUID_TO_BIN('b0000000-0000-0000-0000-000000000001'), 'Early Bird', 'First delivery completed within estimated delivery window', '/badges/early_bird.svg', 'completed_deliveries >= 1'),
(UUID_TO_BIN('b0000000-0000-0000-0000-000000000002'), 'Fast Delivery', 'Avg delivery duration 20% lower than route average', '/badges/fast_delivery.svg', 'avg_delivery_time_diff < 0'),
(UUID_TO_BIN('b0000000-0000-0000-0000-000000000003'), 'Top Traveler', 'Achieve 4.8+ rating and 10+ completed deliveries', '/badges/top_traveler.svg', 'rating >= 4.8 AND completed_deliveries >= 10'),
(UUID_TO_BIN('b0000000-0000-0000-0000-000000000004'), 'AI Champion', 'Successfully matched and completed 5 AI recommended trips', '/badges/ai_champion.svg', 'ai_match_completed >= 5'),
(UUID_TO_BIN('b0000000-0000-0000-0000-000000000005'), 'Trusted Elite', 'Maintain a trust score of 95+ for 3 consecutive months', '/badges/trusted_elite.svg', 'trust_score >= 95');

-- User Badges assignment
INSERT INTO user_badges (id, user_id, badge_id, awarded_at) VALUES
(UUID_TO_BIN('c0000000-0000-0000-0000-000000000001'), UUID_TO_BIN('00000000-0000-0000-0000-000000000001'), UUID_TO_BIN('b0000000-0000-0000-0000-000000000003'), CURRENT_TIMESTAMP),
(UUID_TO_BIN('c0000000-0000-0000-0000-000000000002'), UUID_TO_BIN('00000000-0000-0000-0000-000000000001'), UUID_TO_BIN('b0000000-0000-0000-0000-000000000005'), CURRENT_TIMESTAMP),
(UUID_TO_BIN('c0000000-0000-0000-0000-000000000003'), UUID_TO_BIN('00000000-0000-0000-0000-000000000002'), UUID_TO_BIN('b0000000-0000-0000-0000-000000000001'), CURRENT_TIMESTAMP),
(UUID_TO_BIN('c0000000-0000-0000-0000-000000000004'), UUID_TO_BIN('10000000-0000-0000-0000-000000000001'), UUID_TO_BIN('b0000000-0000-0000-0000-000000000005'), CURRENT_TIMESTAMP);

-- 4. Carbon Savings for Users
INSERT INTO carbon_savings (id, user_id, co2_saved_kg, fuel_saved_liters, total_trips_shared) VALUES
(UUID_TO_BIN('f0000000-0000-0000-0000-000000000001'), UUID_TO_BIN('00000000-0000-0000-0000-000000000001'), 142.50, 58.20, 24),
(UUID_TO_BIN('f0000000-0000-0000-0000-000000000002'), UUID_TO_BIN('00000000-0000-0000-0000-000000000002'), 62.10, 25.40, 10),
(UUID_TO_BIN('f0000000-0000-0000-0000-000000000003'), UUID_TO_BIN('00000000-0000-0000-0000-000000000003'), 15.40, 6.30, 3);

-- 5. Seed Trips (Future / Current Trips)
INSERT INTO trips (id, traveler_id, start_city, end_city, departure_date, arrival_date, luggage_capacity_kg, available_space_kg, vehicle_type, status) VALUES
(
    UUID_TO_BIN('80000000-0000-0000-0000-000000000001'),
    UUID_TO_BIN('00000000-0000-0000-0000-000000000001'),
    'Delhi',
    'Mumbai',
    CURRENT_TIMESTAMP + INTERVAL 2 DAY,
    CURRENT_TIMESTAMP + INTERVAL 2 DAY + INTERVAL 3 HOUR,
    25.00,
    25.00,
    'FLIGHT',
    'PLANNED'
),
(
    UUID_TO_BIN('80000000-0000-0000-0000-000000000002'),
    UUID_TO_BIN('00000000-0000-0000-0000-000000000002'),
    'Bangalore',
    'Chennai',
    CURRENT_TIMESTAMP + INTERVAL 1 DAY,
    CURRENT_TIMESTAMP + INTERVAL 1 DAY + INTERVAL 6 HOUR,
    15.00,
    15.00,
    'TRAIN',
    'PLANNED'
),
(
    UUID_TO_BIN('80000000-0000-0000-0000-000000000003'),
    UUID_TO_BIN('00000000-0000-0000-0000-000000000003'),
    'Pune',
    'Mumbai',
    CURRENT_TIMESTAMP + INTERVAL 12 HOUR,
    CURRENT_TIMESTAMP + INTERVAL 16 HOUR,
    40.00,
    30.00,
    'CAR',
    'PLANNED'
);

-- 6. Seed Parcels
INSERT INTO parcels (id, sender_id, title, description, weight_kg, width_cm, height_cm, depth_cm, start_city, end_city, category, risk_score, packing_recommendation, priority, status) VALUES
(
    UUID_TO_BIN('90000000-0000-0000-0000-000000000001'),
    UUID_TO_BIN('10000000-0000-0000-0000-000000000001'),
    'MacBook Pro Charger',
    'Apple 96W USB-C Power Adapter and Cable',
    0.60,
    10.0, 10.0, 5.0,
    'Delhi',
    'Mumbai',
    'ELECTRONICS',
    5,
    'Wrap in bubble wrap, pack in water-resistant plastic bag.',
    'REGULAR',
    'POSTED'
),
(
    UUID_TO_BIN('90000000-0000-0000-0000-000000000002'),
    UUID_TO_BIN('10000000-0000-0000-0000-000000000001'),
    'Important Land Registration Documents',
    'Original land registry documents in an envelope.',
    0.20,
    30.0, 22.0, 1.0,
    'Delhi',
    'Mumbai',
    'DOCUMENTS',
    0,
    'Place in a rigid cardboard envelope to prevent bending. Add waterproof sleeve.',
    'EMERGENCY',
    'POSTED'
),
(
    UUID_TO_BIN('90000000-0000-0000-0000-000000000003'),
    UUID_TO_BIN('10000000-0000-0000-0000-000000000002'),
    'Homemade Pickles',
    'Spicy mango pickles in a glass container.',
    2.50,
    15.0, 15.0, 20.0,
    'Bangalore',
    'Chennai',
    'LIQUID',
    35,
    'Double seal the jar lid with tape. Wrap in bubble layer. Place in airtight container.',
    'REGULAR',
    'POSTED'
);
