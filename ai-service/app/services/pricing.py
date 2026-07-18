import numpy as np

class DynamicPricingEngine:
    def __init__(self):
        # Default pricing coefficients
        self.base_charge = 120.0  # Base platform charge (INR)
        self.per_km_rate = 0.65   # Base rate per km (INR)
        self.per_kg_rate = 45.0   # Rate per kg (INR)
        
        # Weather/Festival multipliers
        self.weather_multipliers = {
            "CLEAR": 1.0,
            "RAINY": 1.25,
            "HEAVY_RAIN": 1.45,
            "SNOW": 1.60
        }
        self.festival_multipliers = {
            "OFF_SEASON": 1.0,
            "FESTIVAL": 1.30,
            "PEAK_HOLIDAY": 1.50
        }

    def estimate_distance_km(self, start: str, end: str) -> float:
        """
        Estimates route distance between Indian cities.
        """
        distances = {
            ("delhi", "mumbai"): 1415.0,
            ("delhi", "bangalore"): 2150.0,
            ("delhi", "chennai"): 2200.0,
            ("delhi", "pune"): 1430.0,
            ("mumbai", "bangalore"): 980.0,
            ("mumbai", "pune"): 150.0,
            ("bangalore", "chennai"): 350.0,
            ("bangalore", "hyderabad"): 570.0,
            ("pune", "bangalore"): 840.0
        }
        
        pair = (start.lower(), end.lower())
        rev_pair = (end.lower(), start.lower())
        
        if pair in distances:
            return distances[pair]
        if rev_pair in distances:
            return distances[rev_pair]
            
        return 500.0 # Default fallback distance

    def predict_prices(self, start_city: str, end_city: str, weight_kg: float, priority: str = "REGULAR", 
                       weather: str = "CLEAR", season: str = "OFF_SEASON") -> dict:
        """
        Predicts min, recommended, and premium pricing.
        """
        distance_km = self.estimate_distance_km(start_city, end_city)
        
        # Base pricing formula
        distance_cost = distance_km * self.per_km_rate
        weight_cost = weight_kg * self.per_kg_rate
        
        price_base = self.base_charge + distance_cost + weight_cost
        
        # Multipliers
        weather_mult = self.weather_multipliers.get(weather.upper(), 1.0)
        festival_mult = self.festival_multipliers.get(season.upper(), 1.0)
        
        price_adjusted = price_base * weather_mult * festival_mult
        
        # Priority adjustments
        if priority.upper() == "EMERGENCY":
            price_adjusted *= 1.40  # 40% premium for emergency parcel delivery priority

        # Calculate Price ranges
        min_price = float(np.round(price_adjusted * 0.85, 2))
        rec_price = float(np.round(price_adjusted, 2))
        prem_price = float(np.round(price_adjusted * 1.30, 2))

        return {
            "predicted_price_min": min_price,
            "predicted_price_rec": rec_price,
            "predicted_price_prem": prem_price
        }
