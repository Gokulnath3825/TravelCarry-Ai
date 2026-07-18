from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from app.services.matching import TravelerMatcher
from app.services.pricing import DynamicPricingEngine
from app.services.safety import ParcelSafetyScanner

app = FastAPI(title="TravelCarry AI Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize engines
matcher = TravelerMatcher()
pricing_engine = DynamicPricingEngine()

safety_scanner = ParcelSafetyScanner()

# Pydantic schemas
class MatchRequest(BaseModel):
    start_city: str
    end_city: str
    weight_kg: float
    category: str

class TravelerData(BaseModel):
    traveler_id: str
    trip_id: str
    traveler_name: str
    rating: float
    trust_score: int
    vehicle_type: str
    start_city: str
    end_city: str
    available_space_kg: float

class MatchResponse(BaseModel):
    traveler_id: str
    trip_id: str
    traveler_name: str
    rating: float
    trust_score: int
    vehicle_type: str
    match_confidence: float

class PricingRequest(BaseModel):
    start_city: str
    end_city: str
    weight_kg: float
    priority: str
    weather: Optional[str] = "CLEAR"
    season: Optional[str] = "OFF_SEASON"

class PricingResponse(BaseModel):
    predicted_price_min: float
    predicted_price_rec: float
    predicted_price_prem: float

class SafetyRequest(BaseModel):
    category: str
    description: str

class SafetyResponse(BaseModel):
    risk_score: int
    packing_recommendation: str
    classification: str

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "TravelCarry AI Engine"}

@app.post("/ai/match", response_model=List[MatchResponse])
def match_travelers_endpoint(payload: MatchRequest):
    # Simulated active travelers pool (usually loaded from DB)
    sample_travelers = [
        {
            "traveler_id": "00000000-0000-0000-0000-000000000001",
            "trip_id": "t0000000-0000-0000-0000-000000000001",
            "traveler_name": "Rohan Sharma",
            "rating": 4.9,
            "trust_score": 98,
            "vehicle_type": "FLIGHT",
            "start_city": payload.start_city,
            "end_city": payload.end_city,
            "available_space_kg": 25.0
        },
        {
            "traveler_id": "00000000-0000-0000-0000-000000000002",
            "trip_id": "t0000000-0000-0000-0000-000000000002",
            "traveler_name": "Priya Patel",
            "rating": 4.7,
            "trust_score": 88,
            "vehicle_type": "TRAIN",
            "start_city": payload.start_city,
            "end_city": payload.end_city,
            "available_space_kg": 15.0
        },
        {
            "traveler_id": "00000000-0000-0000-0000-000000000003",
            "trip_id": "t0000000-0000-0000-0000-000000000003",
            "traveler_name": "Amit Singh",
            "rating": 4.2,
            "trust_score": 75,
            "vehicle_type": "CAR",
            "start_city": payload.start_city,
            "end_city": payload.end_city,
            "available_space_kg": 30.0
        }
    ]

    matches = matcher.match_travelers(payload.model_dump(), sample_travelers)
    return matches

@app.post("/ai/pricing", response_model=PricingResponse)
def get_pricing_prediction(payload: PricingRequest):
    try:
        prediction = pricing_engine.predict_prices(
            payload.start_city, payload.end_city, payload.weight_kg,
            payload.priority, payload.weather, payload.season
        )
        return prediction
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/ai/parcel-safety", response_model=SafetyResponse)
def scan_parcel_safety_endpoint(payload: SafetyRequest):
    try:
        result = safety_scanner.scan_parcel(payload.category, payload.description)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
