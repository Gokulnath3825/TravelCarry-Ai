# TravelCarry AI - System Design & Architecture Document

Welcome to the System Design documentation for **TravelCarry AI** ("Deliver While You Travel"). This document details the architectural blueprints, database models, class relationships, interactions, and components.

---

## 1. System Architecture Diagram
A high-level view showing the interactions between the React frontend, Spring Boot backend, FastAPI AI service, PostgreSQL database, and third-party integrations.

```mermaid
graph TB
    subgraph Client Tier
        Client[React.js Web App]
    end

    subgraph API Gateway / Security
        Auth[Spring Security / JWT]
        CORS[CORS / Router Filters]
    end

    subgraph Service Tier
        SB[Spring Boot Backend]
        FA[FastAPI AI Service]
    end

    subgraph Storage Tier
        DB[(PostgreSQL - Supabase)]
        Cache[(Redis Cache)]
        S3[Supabase Storage - S3 API]
    end

    subgraph Third-Party Integrations
        Resend[Resend Mail API]
        FCM[Firebase Cloud Messaging]
        OSM[OpenStreetMap / Leaflet]
    end

    Client -->|HTTPS/WSS| Auth
    Auth --> CORS
    CORS --> SB
    SB -->|JDBC| DB
    SB -->|Redis Protocol| Cache
    SB -->|HTTP API| FA
    SB -->|SMTP/HTTP| Resend
    SB -->|Push Gateway| FCM
    FA -->|SQLAlchemy| DB
    Client -->|Geocode / Map Tiles| OSM
    Client -->|Direct Uploads| S3
```

---

## 2. Entity-Relationship (ER) Diagram
Shows the database tables, fields, constraints, and relationships.

```mermaid
erDiagram
    USERS ||--o| WALLET : "has a"
    USERS ||--o{ TRIPS : "registers"
    USERS ||--o{ PARCELS : "posts"
    USERS ||--o{ BOOKINGS : "undertakes (as traveler)"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ USER_BADGES : "earns"
    USERS ||--o| CARBON_SAVINGS : "accumulates"
    USERS ||--o{ SUPPORT_TICKETS : "submits"

    WALLET ||--o{ WALLET_HISTORY : "tracks balance shifts"

    TRIPS ||--o{ BOOKINGS : "contains"
    PARCELS ||--|| BOOKINGS : "is assigned to"

    BOOKINGS ||--|| TRACKING : "monitors journey"
    BOOKINGS ||--o{ TRANSACTIONS : "triggers payments"
    BOOKINGS ||--o{ RATINGS : "gets rated"
    BOOKINGS ||--|| CHAT : "initiates"

    RATINGS ||--|| REVIEWS : "details text feedback"
    REWARD_BADGES ||--o{ USER_BADGES : "mapped to users"
    CHATS ||--o{ MESSAGES : "contains text logs"

    PARCELS ||--o{ AI_PREDICTIONS : "analyzed for pricing/matching"
    TRIPS ||--o{ AI_PREDICTIONS : "correlated for matching"
```

---

## 3. Use Case Diagram
Visualizes user roles (Traveler, Sender, Admin) and their interactions with the system.

```mermaid
left-to-right direction
flowchart TD
    subgraph Users
        Sender[Sender]
        Traveler[Traveler]
        Admin[System Admin]
    end

    subgraph System Features
        UC1(Create Trip)
        UC2(Post Parcel)
        UC3(Find AI Matches)
        UC4(Approve Booking)
        UC5(Update Real-time Tracking)
        UC6(Generate OTP Verification)
        UC7(Execute Payment Escrow)
        UC8(View Trust/Carbon Dashboard)
        UC9(Monitor Live Fraud Metrics)
    end

    Traveler --> UC1
    Sender --> UC2
    Sender --> UC3
    Traveler --> UC4
    Traveler --> UC5
    Sender --> UC6
    Traveler --> UC6
    Sender --> UC7
    Traveler --> UC8
    Sender --> UC8
    Admin --> UC9
```

---

## 4. Class Diagram
Class blueprints for the Spring Boot backend layer modeling the main entity structures.

```mermaid
classDiagram
    class User {
        +UUID id
        +String email
        +String passwordHash
        +String firstName
        +String lastName
        +String role
        +Integer trustScore
        +String trustLevel
        +Double rating
        +register()
        +login()
    }
    class Trip {
        +UUID id
        +User traveler
        +String startCity
        +String endCity
        +LocalDateTime departureDate
        +LocalDateTime arrivalDate
        +Double availableSpaceKg
        +String vehicleType
        +planTrip()
    }
    class Parcel {
        +UUID id
        +User sender
        +String title
        +Double weightKg
        +String category
        +String priority
        +Integer riskScore
        +createParcel()
    }
    class Booking {
        +UUID id
        +Parcel parcel
        +Trip trip
        +Double price
        +String pickupOtp
        +String deliveryOtp
        +String status
        +initiate()
        +verifyOtp()
    }
    class Wallet {
        +UUID id
        +User user
        +Double balance
        +addFunds()
        +deductEscrow()
    }

    User "1" --> "*" Trip : schedules
    User "1" --> "*" Parcel : owns
    User "1" --> "1" Wallet : holds
    Trip "1" --> "*" Booking : accommodates
    Parcel "1" --> "1" Booking : associated
```

---

## 5. Sequence Diagram (Booking & Match Flow)
Illustrates step-by-step requests and responses when a Sender lists a parcel and matches with a traveler.

```mermaid
sequenceDiagram
    autonumber
    actor Sender
    participant FE as React Frontend
    participant BE as Spring Boot Backend
    participant AI as FastAPI AI Service
    actor Traveler

    Sender->>FE: Create parcel & request AI match
    FE->>BE: POST /api/parcels
    BE->>AI: POST /ai/match (parcel parameters)
    Note over AI: NetworkX overlap routing<br>Trust Score weighting<br>Capacity validation
    AI-->>BE: Top 10 Travelers + confidence score (e.g. 96%)
    BE-->>FE: Return AI Match Results
    Sender->>FE: Select Traveler & Pay
    FE->>BE: POST /api/bookings (Trip ID, Parcel ID)
    BE->>BE: Place funds in escrow (Wallet deduct)
    BE->>Traveler: Push Notification (New Match Proposal)
    Traveler->>BE: PUT /api/bookings/{id}/accept
    BE->>Sender: Notification (Booking Confirmed)
```

---

## 6. Component Diagram
Decomposes the backend services into separate logical modules.

```mermaid
graph LR
    subgraph Spring Boot Backend Modules
        AuthCtrl[Auth Controller] --> AuthService[Auth Service]
        TripCtrl[Trip Controller] --> TripService[Trip Service]
        ParcelCtrl[Parcel Controller] --> ParcelService[Parcel Service]
        BookingCtrl[Booking Controller] --> BookingService[Booking Service]
        WalletCtrl[Wallet Controller] --> WalletService[Wallet Service]
        
        AuthService --> Security[Spring Security & JWT]
        BookingService --> NotificationService[FCM Notification Service]
        BookingService --> MailService[Resend SMTP service]
        ParcelService --> AIServiceConnector[AI FastAPI client]
    end
```

---

## 7. Deployment Diagram
Illustrates the physical architecture where elements are deployed (Vercel, Render, Supabase).

```mermaid
graph TD
    subgraph Vercel CDN Cloud
        FE[React Static Assets CDN]
    end

    subgraph Render Platform
        subgraph Docker Container 1
            BE[Java 21 Spring Boot App]
        end
        subgraph Docker Container 2
            AI[FastAPI Python App]
        end
    end

    subgraph Supabase cloud
        DB[(PostgreSQL Database)]
        Storage[(S3 Storage Buckets)]
    end

    FE -->|API requests| BE
    FE -->|Asset uploads| Storage
    BE -->|HTTP proxy queries| AI
    BE -->|JDBC Connection Pool| DB
    AI -->|Dataframe loads| DB
```
