# Cabs App - Production-Ready Flutter Cab Booking App

This project is a functional prototype of a cab booking application (Passenger + Driver) built with Flutter and Supabase.

## 🚀 Features

- **Auth:** Phone login with OTP (Supabase).
- **Role-Based:** Separate dashboards for Passengers and Drivers.
- **Maps:** Google Maps integration for location tracking and search.
- **Search:** Google Places API for address autocomplete.
- **Fare:** Real-time fare estimation based on distance.
- **Chat:** Real-time in-app messaging between passenger and driver.
- **Trips:** Full lifecycle management (Request -> Accept -> Arrive -> Verify -> Start -> Complete).

## 🛠️ Setup Instructions

### 1. Environment Variables
Create a `.env` file (one has been provided as a template) and fill in your credentials.
Since this project uses `String.fromEnvironment`, you must pass these variables at build time.

### 2. Database Setup
Execute the SQL script provided in `supabase_setup.sql` in your Supabase SQL Editor. This will create the necessary tables (`profiles`, `bookings`, `messages`) and set up Row Level Security (RLS).

### 3. Run the App
Run the following command, replacing the placeholders with your actual keys:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

## 📦 Tech Stack
- **Flutter** (State Management: Riverpod)
- **Supabase** (Auth, Database, Realtime, Storage)
- **Google Maps** (Maps & Distance Matrix)
- **GoRouter** (Navigation)
- **Dio** (HTTP)
