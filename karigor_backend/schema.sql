-- karigor_backend/schema.sql
-- Database schema for Karigor Khoj

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('seeker', 'karigor')),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS karigor_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    service_category VARCHAR(100) DEFAULT 'প্লাম্বার',
    is_verified BOOLEAN DEFAULT true,
    is_online BOOLEAN DEFAULT true,
    rating NUMERIC(3,2) DEFAULT 5.00,
    review_count INTEGER DEFAULT 0,
    bio TEXT DEFAULT '',
    latitude DOUBLE PRECISION DEFAULT 23.8103,
    longitude DOUBLE PRECISION DEFAULT 90.4125,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS job_requests (
    id SERIAL PRIMARY KEY,
    seeker_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    karigor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    location TEXT,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
    amount NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    seeker_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    karigor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_karigor_profiles_category ON karigor_profiles(service_category);
CREATE INDEX IF NOT EXISTS idx_karigor_profiles_location ON karigor_profiles(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_job_requests_seeker ON job_requests(seeker_id);
CREATE INDEX IF NOT EXISTS idx_job_requests_karigor ON job_requests(karigor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_karigor ON reviews(karigor_id);
