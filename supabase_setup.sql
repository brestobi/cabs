-- 1. Profiles Table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  role TEXT CHECK (role IN ('passenger', 'driver')),
  phone TEXT UNIQUE NOT NULL,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  rating DOUBLE PRECISION DEFAULT 0.0,
  wallet_balance DOUBLE PRECISION DEFAULT 0.0,
  is_verified BOOLEAN DEFAULT FALSE,
  is_online BOOLEAN DEFAULT FALSE,
  current_location JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Bookings Table
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  passenger_id UUID REFERENCES profiles(id) NOT NULL,
  driver_id UUID REFERENCES profiles(id),
  pickup_location JSONB NOT NULL,
  dropoff_location JSONB NOT NULL,
  pickup_address TEXT NOT NULL,
  dropoff_address TEXT NOT NULL,
  status TEXT CHECK (status IN ('pending', 'accepted', 'arrived', 'started', 'completed', 'cancelled')) DEFAULT 'pending',
  fare_estimate DOUBLE PRECISION NOT NULL,
  final_fare DOUBLE PRECISION,
  payment_method TEXT DEFAULT 'cash',
  pickup_verification_code TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 3. Messages Table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES profiles(id) NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS)

-- Profiles: Users can read all profiles (to see driver/passenger info), but only update their own.
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile." ON profiles FOR UPDATE USING (auth.uid() = id);

-- Bookings: Passengers can see their own bookings. Drivers can see pending bookings and bookings assigned to them.
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see their own bookings." ON bookings FOR SELECT USING (
  auth.uid() = passenger_id OR auth.uid() = driver_id OR status = 'pending'
);
CREATE POLICY "Passengers can insert bookings." ON bookings FOR INSERT WITH CHECK (auth.uid() = passenger_id);
CREATE POLICY "Drivers can update bookings." ON bookings FOR UPDATE USING (
  auth.uid() = driver_id OR (status = 'pending' AND auth.uid() IN (SELECT id FROM profiles WHERE role = 'driver'))
);

-- Messages: Participants of a booking can see and send messages.
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Booking participants can see messages." ON messages FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM bookings 
    WHERE bookings.id = messages.booking_id 
    AND (bookings.passenger_id = auth.uid() OR bookings.driver_id = auth.uid())
  )
);
CREATE POLICY "Booking participants can send messages." ON messages FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM bookings 
    WHERE bookings.id = messages.booking_id 
    AND (bookings.passenger_id = auth.uid() OR bookings.driver_id = auth.uid())
  ) AND auth.uid() = sender_id
);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
