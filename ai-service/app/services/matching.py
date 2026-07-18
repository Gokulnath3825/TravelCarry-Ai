import networkx as nx
import numpy as np

class TravelerMatcher:
    def __init__(self):
        # Build a graph of Indian cities for route overlap simulations
        self.G = nx.Graph()
        cities = ["Delhi", "Mumbai", "Bangalore", "Chennai", "Pune", "Hyderabad", "Kolkata", "Ahmedabad", "Jaipur"]
        self.G.add_nodes_from(cities)
        
        # Add travel paths with weights (representing default route distances in km)
        edges = [
            ("Delhi", "Jaipur", 270), ("Delhi", "Ahmedabad", 950), ("Delhi", "Mumbai", 1400),
            ("Mumbai", "Pune", 150), ("Mumbai", "Ahmedabad", 530), ("Mumbai", "Bangalore", 1000),
            ("Pune", "Bangalore", 840), ("Bangalore", "Chennai", 350), ("Bangalore", "Hyderabad", 570),
            ("Hyderabad", "Chennai", 630), ("Hyderabad", "Pune", 560), ("Kolkata", "Delhi", 1500),
            ("Jaipur", "Ahmedabad", 680)
        ]
        self.G.add_weighted_edges_from(edges)

    def calculate_route_similarity(self, traveler_start: str, traveler_end: str, parcel_start: str, parcel_end: str) -> float:
        """
        Calculates similarity using route distance paths in NetworkX graph.
        Returns similarity score between 0.0 and 1.0.
        """
        try:
            # If cities are not in the graph, add them dynamically
            for c in [traveler_start, traveler_end, parcel_start, parcel_end]:
                if not self.G.has_node(c):
                    self.G.add_node(c)
                    # Connect to nearest major node (e.g. Bangalore) with default cost
                    self.G.add_edge(c, "Bangalore", weight=500)

            # Exact route match
            if traveler_start.lower() == parcel_start.lower() and traveler_end.lower() == parcel_end.lower():
                return 1.0
            
            # Check route overlap using shortest path lengths
            t_path_len = nx.shortest_path_length(self.G, source=traveler_start, target=traveler_end, weight='weight')
            p_path_len = nx.shortest_path_length(self.G, source=parcel_start, target=parcel_end, weight='weight')
            
            # Simple overlap coefficient based on path length differences
            diff = abs(t_path_len - p_path_len)
            max_len = max(t_path_len, p_path_len, 1)
            overlap_score = max(0.0, 1.0 - (diff / max_len))
            return float(overlap_score)
        except Exception:
            # Fallback direct string match comparison
            if traveler_start.lower() == parcel_start.lower() and traveler_end.lower() == parcel_end.lower():
                return 1.0
            return 0.1

    def match_travelers(self, parcel: dict, travelers: list) -> list:
        """
        parcel: { 'start_city': str, 'end_city': str, 'weight_kg': float, 'category': str }
        travelers: list of traveler dictionaries
        Returns ranked list of matching travelers with confidence scores.
        """
        matches = []
        for t in travelers:
            # Check if traveler has enough weight capacity
            if t.get("available_space_kg", 0) < parcel.get("weight_kg", 1):
                continue

            # 1. Route similarity (Weight: 40%)
            route_sim = self.calculate_route_similarity(
                t.get("start_city"), t.get("end_city"),
                parcel.get("start_city"), parcel.get("end_city")
            )

            # 2. Trust Score (Weight: 30%)
            trust_score = t.get("trust_score", 50) / 100.0

            # 3. Rating score (Weight: 20%)
            rating_score = t.get("rating", 0.0) / 5.0

            # 4. Vehicle speed multiplier (Weight: 10%)
            # Flight is faster (high reliability), Car is medium, Bus/Train is standard
            vehicle = t.get("vehicle_type", "TRAIN").upper()
            vehicle_mult = 1.0 if vehicle == "FLIGHT" else (0.8 if vehicle == "CAR" else 0.6)

            # Calculate total match confidence score
            confidence = (route_sim * 0.40) + (trust_score * 0.30) + (rating_score * 0.20) + (vehicle_mult * 0.10)
            confidence_percentage = min(100.0, max(0.0, round(confidence * 100, 2)))

            matches.append({
                "traveler_id": t.get("traveler_id"),
                "trip_id": t.get("trip_id"),
                "traveler_name": t.get("traveler_name"),
                "rating": t.get("rating"),
                "trust_score": t.get("trust_score"),
                "vehicle_type": t.get("vehicle_type"),
                "match_confidence": confidence_percentage
            })

        # Sort matches by confidence descending
        matches.sort(key=lambda x: x["match_confidence"], reverse=True)
        return matches[:10]
