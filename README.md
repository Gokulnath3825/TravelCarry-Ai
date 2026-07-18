# TravelCarry AI - "Deliver While You Travel"

TravelCarry AI is an intelligent peer-to-peer logistics ecosystem that connects travelers who have spare luggage capacity with individuals who need packages delivered. By utilizing existing passenger transits (flights, trains, cars), we help senders save courier fees, travelers monetize travel space, and significantly reduce carbon footprints.

---

## 🚀 Key Features

1. **Smart Traveler Match AI**: Uses route overlap similarity (via NetworkX graphs), weight capacity thresholds, traveler trust scores, and vehicle parameters to suggest optimal travelers.
2. **Dynamic AI Pricing**: Computes minimum, recommended, and premium prices based on shipping distance, payload weight, weather indicators, season parameters, and urgent priorities.
3. **AI Trust Engine**: Generates numerical trust scores (0-100) and tiers (Gold Trusted, Silver, Verified, New User) based on identity logs, completed deliveries, and cancellation metrics.
4. **AI Parcel Safety Scanner**: Checks descriptions for safety risks and recommends optimal packing procedures per classification category.
5. **Real-time Transit Tracking**: Features interactive transit maps showing shipment coordinates and ETAs.
6. **Secure OTP Handshake**: Protects delivery transactions with distinct 6-digit OTPs verifying pickup and delivery stages before releasing held escrow wallet funds.
7. **Green Footprint Tracker**: Visualizes CO₂ and fuel savings comparing traveler transport to commercial cargo planes.
8. **Digital Wallet System**: Supports loading money, holding escrow, and withdrawing earnings in INR.

---

## 🛠️ Technology Stack

- **Frontend**: React (Vite), Glassmorphism and Dark Mode CSS design system, Lucide icons.
- **Backend**: Spring Boot 3.3, Java 21, Spring Security (JWT authentication), Spring Data JPA.
- **AI Service**: Python FastAPI, NetworkX route graphs, NumPy, Pandas, scikit-learn.
- **Database**: PostgreSQL (Supabase / local Docker).

---

## 📂 Project Structure

```
TravelCarry AI/
├── docs/                      # Architectural designs and system design docs
├── database/                  # PostgreSQL schema and seed files
├── backend/                   # Spring Boot Java 21 service
├── ai-service/                # Python FastAPI matching service
└── frontend/                  # React Vite client
```

---

## 🐳 Quick Start with Docker Compose

Ensure Docker and Docker Compose are installed, then run the following in the project root:

```bash
docker-compose up --build
```

This single command boots:
1. **PostgreSQL Database** on port `5432` (auto-loaded with schemas and seed data).
2. **FastAPI AI Service** on port `8000`.
3. **Spring Boot Backend** on port `8080`.
4. **React Frontend Web Client** on port `80` (or local port).

---

## 💻 Manual Setup (Local Development)

### 1. Database
Create a database named `travelcarry` in PostgreSQL, then execute the schema DDL and seeds:
```bash
psql -h localhost -U postgres -d travelcarry -f database/schema.sql
psql -h localhost -U postgres -d travelcarry -f database/seed.sql
```

### 2. FastAPI Service
```bash
cd ai-service
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
API endpoints documentation will be visible at: `http://localhost:8000/docs`.

### 3. Spring Boot Backend
Ensure Java 21 is active:
```bash
cd backend
mvn clean spring-boot:run
```
Swagger UI API specs will be visible at: `http://localhost:8080/swagger-ui.html`.

### 4. React Frontend
```bash
cd frontend
npm install
npm run dev
```
Open your browser at: `http://localhost:5173`.

---

## 🛣️ API Endpoints

### Authentication
- `POST /api/auth/register` - Create account (Traveler / Sender)
- `POST /api/auth/login` - Get JWT Authorization token
- `POST /api/auth/otp/send` - Generate OTP
- `POST /api/auth/otp/verify` - Verify OTP

### Trips & Parcels
- `POST /api/trips` - Register travel schedule
- `GET /api/trips/search` - Search trips matching cities
- `POST /api/parcels` - Register parcel cargo listing
- `GET /api/parcels/{id}/ai-matches` - Request AI matching travelers

### Bookings & Shipments
- `POST /api/bookings` - Create transaction booking & hold escrow funds
- `PUT /api/bookings/{id}/accept` - Traveler accepts request
- `POST /api/bookings/{id}/verify-pickup` - Verify pickup OTP (starts transit)
- `POST /api/bookings/{id}/verify-delivery` - Verify delivery OTP (releases payout)

### Wallet & Carbon
- `GET /api/wallets/user/{userId}` - Check wallet history
- `POST /api/wallets/user/{userId}/deposit` - Add balance funds
- `GET /api/analytics/user/{userId}/profile-summary` - Unlocked badges & green stats
