class ParcelSafetyScanner:
    def __init__(self):
        # List of forbidden or extremely high risk items
        self.prohibited_keywords = ["drug", "gun", "weapon", "explosive", "ammunition", "acid", "battery", "combustible", "flammable"]
        
        # Risk guidelines per category
        self.risk_mapping = {
            "ELECTRONICS": {"score": 25, "rec": "Ensure device is powered off, wrap in anti-static film, and cover with double bubble wrap layers inside a hard shell container."},
            "FRAGILE": {"score": 70, "rec": "Wrap individual items in thick bubble sheets. Label the exterior box clearly as FRAGILE. Pack without empty spaces using filler peanuts."},
            "FOOD": {"score": 15, "rec": "Store inside clean airtight containers. If perishable, place inside insulated cooling bags with dry ice blocks."},
            "LIQUID": {"score": 50, "rec": "Tape the container caps tightly. Place bottles inside a leakproof ziploc bag to prevent accidental spills into traveler luggage."},
            "DOCUMENTS": {"score": 5, "rec": "Place inside a rigid cardboard document sleeve to prevent bends. Seal in a plastic folder for water protection."},
            "REGULAR": {"score": 10, "rec": "Standard wrapping inside a durable cardboard shipping box."}
        }

    def scan_parcel(self, category: str, description: str) -> dict:
        desc_lower = description.lower()
        
        # Check for banned items
        found_prohibited = [kw for kw in self.prohibited_keywords if kw in desc_lower]
        
        if found_prohibited:
            return {
                "risk_score": 100,
                "packing_recommendation": "CRITICAL WARNING: This parcel contains items that are forbidden from transport. Delivery rejected.",
                "classification": "PROHIBITED"
            }
            
        cat_info = self.risk_mapping.get(category.upper(), self.risk_mapping["REGULAR"])
        
        # Calculate dynamic risk adjustments based on descriptions
        risk_score = cat_info["score"]
        if "glass" in desc_lower or "ceramic" in desc_lower:
            risk_score = min(95, risk_score + 25)
        if "expensive" in desc_lower or "gold" in desc_lower or "laptop" in desc_lower:
            risk_score = min(95, risk_score + 15)

        return {
            "risk_score": risk_score,
            "packing_recommendation": cat_info["rec"],
            "classification": category.upper()
        }
