// TravelCarry AI API Service Client with Local Fallback
const BASE_URL = 'http://localhost:8080/api';

const getHeaders = () => {
  const token = localStorage.getItem('token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
  };
};

// Simulated mock database for fallback
const mockDb = {
  trips: [
    { id: 't-1', startCity: 'Delhi', endCity: 'Mumbai', departureDate: '2026-07-20T10:00:00Z', arrivalDate: '2026-07-20T13:00:00Z', luggageCapacityKg: 25, availableSpaceKg: 25, vehicleType: 'FLIGHT', status: 'PLANNED', travelerName: 'Rohan Sharma' }
  ],
  parcels: [
    { id: 'p-1', title: 'MacBook Pro Charger', description: 'Apple 96W charger', weightKg: 0.6, category: 'ELECTRONICS', startCity: 'Delhi', endCity: 'Mumbai', riskScore: 25, priority: 'REGULAR', status: 'POSTED' }
  ],
  bookings: [
    { id: 'b-1', parcelId: 'p-1', parcelTitle: 'MacBook Pro Charger', tripId: 't-1', travelerId: 't-user', travelerName: 'Rohan Sharma', senderName: 'Sneha Rao', price: 650.00, commission: 97.5, basePrice: 552.5, status: 'PENDING', pickupOtp: '483921', deliveryOtp: '928374' }
  ],
  wallet: {
    balance: 5450.00,
    currency: 'INR',
    history: [
      { id: 'wh-1', amount: 1500, type: 'DEPOSIT', description: 'UPI Load', createdAt: new Date().toISOString() }
    ]
  },
  carbon: {
    co2SavedKg: 142.50,
    fuelSavedLiters: 58.20,
    totalTripsShared: 14
  },
  chats: {
    'b-1': { id: 'c-1', bookingId: 'b-1', messages: [] }
  }
};

const handleFetch = async (endpoint, options = {}) => {
  try {
    const res = await fetch(`${BASE_URL}${endpoint}`, {
      ...options,
      headers: { ...getHeaders(), ...options.headers }
    });
    if (!res.ok) throw new Error('API Error');
    return await res.json();
  } catch (error) {
    console.warn(`Fetch to ${endpoint} failed. Using mock local data fallback.`);
    return handleFallback(endpoint, options);
  }
};

const handleFallback = (endpoint, options) => {
  // Parsing URL query params
  const url = new URL(endpoint, 'http://localhost');
  const path = url.pathname;
  
  if (path.startsWith('/auth/login')) {
    const body = JSON.parse(options.body);
    const role = body.email.includes('traveler') ? 'TRAVELER' : 'SENDER';
    return {
      token: 'mock-jwt-token',
      userId: role === 'TRAVELER' ? '00000000-0000-0000-0000-000000000001' : '10000000-0000-0000-0000-000000000001',
      email: body.email,
      firstName: role === 'TRAVELER' ? 'Rohan' : 'Sneha',
      lastName: role === 'TRAVELER' ? 'Sharma' : 'Rao',
      role: role
    };
  }

  if (path.startsWith('/auth/register')) {
    const body = JSON.parse(options.body);
    return {
      token: 'mock-jwt-token',
      userId: 'mock-uuid',
      email: body.email,
      firstName: body.firstName,
      lastName: body.lastName,
      role: body.role
    };
  }

  if (path.startsWith('/trips')) {
    if (options.method === 'POST') {
      const body = JSON.parse(options.body);
      const newTrip = { id: `t-${Date.now()}`, ...body, travelerName: 'Rohan Sharma', status: 'PLANNED' };
      mockDb.trips.push(newTrip);
      return newTrip;
    }
    return mockDb.trips;
  }

  if (path.startsWith('/parcels')) {
    if (options.method === 'POST') {
      const body = JSON.parse(options.body);
      const newParcel = { id: `p-${Date.now()}`, ...body, status: 'POSTED', riskScore: 10, packingRecommendation: 'Double wrap with bubble pack' };
      mockDb.parcels.push(newParcel);
      return newParcel;
    }
    if (path.endsWith('/ai-matches')) {
      return [
        { travelerId: 't-1', tripId: 't-1', travelerName: 'Rohan Sharma (Flight)', rating: 4.9, trustScore: 98, vehicleType: 'FLIGHT', matchConfidence: 96.5 },
        { travelerId: 't-2', tripId: 't-2', travelerName: 'Priya Patel (Train)', rating: 4.7, trustScore: 88, vehicleType: 'TRAIN', matchConfidence: 84.0 }
      ];
    }
    return mockDb.parcels;
  }

  if (path.startsWith('/bookings')) {
    if (options.method === 'POST') {
      const tripId = url.searchParams.get('tripId');
      const parcelId = url.searchParams.get('parcelId');
      const price = parseFloat(url.searchParams.get('price'));
      const newBooking = {
        id: `b-${Date.now()}`,
        parcelId,
        parcelTitle: 'Parcel Shipment',
        tripId,
        travelerId: 't-1',
        travelerName: 'Rohan Sharma',
        senderName: 'Sneha Rao',
        price,
        commission: price * 0.15,
        basePrice: price * 0.85,
        status: 'PENDING',
        pickupOtp: '123456',
        deliveryOtp: '654321'
      };
      mockDb.bookings.push(newBooking);
      return newBooking;
    }
    return mockDb.bookings;
  }

  if (path.startsWith('/wallets')) {
    return mockDb.wallet;
  }

  if (path.startsWith('/analytics/user')) {
    if (path.endsWith('/carbon')) {
      return mockDb.carbon;
    }
    return {
      userId: 'user-id',
      firstName: 'Rohan',
      lastName: 'Sharma',
      role: 'TRAVELER',
      rating: 4.85,
      trustScore: 96,
      trustLevel: 'Gold Trusted',
      completedDeliveries: 24,
      co2SavedKg: 142.50,
      fuelSavedLiters: 58.20,
      badgesCount: 3
    };
  }

  return {};
};

export const api = {
  auth: {
    login: (credentials) => handleFetch('/auth/login', { method: 'POST', body: JSON.stringify(credentials) }),
    register: (details) => handleFetch('/auth/register', { method: 'POST', body: JSON.stringify(details) }),
    sendOtp: (contact, purpose) => handleFetch(`/auth/otp/send?contact=${contact}&purpose=${purpose}`, { method: 'POST' }),
    verifyOtp: (contact, code, purpose) => handleFetch(`/auth/otp/verify?contact=${contact}&code=${code}&purpose=${purpose}`, { method: 'POST' }),
  },
  trips: {
    create: (trip, travelerId) => handleFetch(`/trips?travelerId=${travelerId}`, { method: 'POST', body: JSON.stringify(trip) }),
    getByTraveler: (travelerId) => handleFetch(`/trips/traveler/${travelerId}`),
    search: (start, end) => handleFetch(`/trips/search?startCity=${start}&endCity=${end}`),
  },
  parcels: {
    create: (parcel, senderId) => handleFetch(`/parcels?senderId=${senderId}`, { method: 'POST', body: JSON.stringify(parcel) }),
    getBySender: (senderId) => handleFetch(`/parcels/sender/${senderId}`),
    getMatches: (id) => handleFetch(`/parcels/${id}/ai-matches`),
    getPricing: (start, end, weight, priority) => handleFetch(`/parcels/ai-pricing?startCity=${start}&endCity=${end}&weightKg=${weight}&priority=${priority}`),
  },
  bookings: {
    create: (tripId, parcelId, price) => handleFetch(`/bookings?tripId=${tripId}&parcelId=${parcelId}&price=${price}`, { method: 'POST' }),
    getById: (id) => handleFetch(`/bookings/${id}`),
    accept: (id) => handleFetch(`/bookings/${id}/accept`, { method: 'PUT' }),
    verifyPickup: (id, otp) => handleFetch(`/bookings/${id}/verify-pickup?otp=${otp}`, { method: 'POST' }),
    verifyDelivery: (id, otp) => handleFetch(`/bookings/${id}/verify-delivery?otp=${otp}`, { method: 'POST' }),
    getByTraveler: (id) => handleFetch(`/bookings/traveler/${id}`),
    getBySender: (id) => handleFetch(`/bookings/sender/${id}`),
  },
  wallet: {
    getByUser: (userId) => handleFetch(`/wallets/user/${userId}`),
    deposit: (userId, amount, desc) => handleFetch(`/wallets/user/${userId}/deposit?amount=${amount}&description=${desc}`, { method: 'POST' }),
    withdraw: (userId, amount, desc) => handleFetch(`/wallets/user/${userId}/withdraw?amount=${amount}&description=${desc}`, { method: 'POST' }),
  },
  analytics: {
    getProfile: (userId) => handleFetch(`/analytics/user/${userId}/profile-summary`),
    getCarbon: (userId) => handleFetch(`/analytics/user/${userId}/carbon`),
    getBadges: (userId) => handleFetch(`/analytics/user/${userId}/badges`),
    getAdminDashboard: () => handleFetch('/analytics/admin/dashboard'),
  }
};
