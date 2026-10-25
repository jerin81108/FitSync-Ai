-- ==============================================================================
-- FITSYNC AI - Complete Production PostgreSQL Schema (Supabase)
-- Initial Migration: 20261025000000_fitsync_initial_schema.sql
-- ==============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 1. PROFILES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    age INT CHECK (age >= 13 AND age <= 120),
    gender TEXT CHECK (gender IN ('male', 'female', 'non_binary', 'prefer_not_to_say')),
    height_cm NUMERIC(5, 2),
    weight_kg NUMERIC(5, 2),
    primary_goal TEXT NOT NULL DEFAULT 'stay_active' 
        CHECK (primary_goal IN ('stay_active', 'lose_weight', 'build_strength', 'reduce_stress')),
    daily_free_minutes INT DEFAULT 45,
    preferred_workout_place TEXT DEFAULT 'both' 
        CHECK (preferred_workout_place IN ('indoor', 'outdoor', 'both')),
    cycle_tracking_enabled BOOLEAN DEFAULT FALSE,
    tone_preference TEXT DEFAULT 'friendly' 
        CHECK (tone_preference IN ('friendly', 'calm', 'playful')),
    preferred_notification_time TEXT DEFAULT '07:30',
    preferred_language TEXT DEFAULT 'en' CHECK (preferred_language IN ('en', 'ta', 'hi')),
    is_premium BOOLEAN DEFAULT FALSE,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
    ON public.profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- ==============================================================================
-- 2. DAILY CHECKINS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.daily_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    checkin_date DATE NOT NULL,
    mood_emoji TEXT NOT NULL CHECK (mood_emoji IN ('great', 'good', 'okay', 'low', 'exhausted')),
    mood_score INT NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
    stress_level INT NOT NULL CHECK (stress_level BETWEEN 1 AND 5),
    sleep_hours NUMERIC(3, 1) NOT NULL CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
    sleep_quality INT NOT NULL CHECK (sleep_quality BETWEEN 1 AND 5),
    yesterday_workout_intensity INT NOT NULL DEFAULT 2 CHECK (yesterday_workout_intensity BETWEEN 0 AND 5),
    is_heavy_day BOOLEAN DEFAULT FALSE,
    schedule_load_rating INT DEFAULT 0 CHECK (schedule_load_rating BETWEEN 0 AND 100),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_checkin_per_day UNIQUE (user_id, checkin_date)
);

-- RLS: Daily Checkins
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own checkins" 
    ON public.daily_checkins FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own checkins" 
    ON public.daily_checkins FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own checkins" 
    ON public.daily_checkins FOR UPDATE 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 3. READINESS SCORES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.readiness_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    score_date DATE NOT NULL,
    score INT NOT NULL CHECK (score BETWEEN 0 AND 100),
    band TEXT NOT NULL CHECK (band IN ('rest', 'light', 'moderate', 'optimal', 'peak')),
    schedule_load_factor NUMERIC(4, 2) NOT NULL,
    sleep_factor NUMERIC(4, 2) NOT NULL,
    stress_factor NUMERIC(4, 2) NOT NULL,
    recovery_factor NUMERIC(4, 2) NOT NULL,
    available_time_factor NUMERIC(4, 2) NOT NULL,
    cycle_modifier NUMERIC(4, 2) DEFAULT 0.0,
    injury_penalty NUMERIC(4, 2) DEFAULT 0.0,
    explanation JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_readiness_per_day UNIQUE (user_id, score_date)
);

-- RLS: Readiness Scores
ALTER TABLE public.readiness_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own readiness scores" 
    ON public.readiness_scores FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own readiness scores" 
    ON public.readiness_scores FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 4. TARGETS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    target_date DATE NOT NULL,
    base_steps INT NOT NULL DEFAULT 8000,
    adapted_steps INT NOT NULL,
    base_active_minutes INT NOT NULL DEFAULT 30,
    adapted_active_minutes INT NOT NULL,
    scaling_percentage INT NOT NULL,
    suggested_workout_id TEXT,
    user_manual_override INT DEFAULT 0 CHECK (user_manual_override IN (-1, 0, 1)),
    is_push_day BOOLEAN DEFAULT FALSE,
    is_intentional_rest_day BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    steps_achieved INT DEFAULT 0,
    active_minutes_achieved INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_target_per_day UNIQUE (user_id, target_date)
);

-- RLS: Targets
ALTER TABLE public.targets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own targets" 
    ON public.targets FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. WORKOUTS LIBRARY TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.workouts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    duration_minutes INT NOT NULL,
    intensity INT NOT NULL CHECK (intensity BETWEEN 1 AND 5),
    equipment TEXT NOT NULL,
    body_region TEXT NOT NULL CHECK (body_region IN ('full_body', 'upper_body', 'lower_body', 'core', 'seated_mobility')),
    tags TEXT[] NOT NULL DEFAULT '{}',
    instruction_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    illustration_key TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Workouts (read-only for authenticated, write for service_role)
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read for workouts" 
    ON public.workouts FOR SELECT 
    TO authenticated 
    USING (true);

-- ==============================================================================
-- 6. WORKOUT LOGS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.workout_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    workout_id TEXT NOT NULL REFERENCES public.workouts(id),
    log_date DATE NOT NULL,
    duration_seconds INT NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    perceived_exertion INT CHECK (perceived_exertion BETWEEN 1 AND 5),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Workout Logs
ALTER TABLE public.workout_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own workout logs" 
    ON public.workout_logs FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 7. STREAKS TABLE (No-Guilt Flex Streak)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.streaks (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    total_active_days INT NOT NULL DEFAULT 0,
    total_intentional_rest_days INT NOT NULL DEFAULT 0,
    last_activity_date DATE,
    streak_freezes_left INT NOT NULL DEFAULT 2,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Streaks
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own streaks" 
    ON public.streaks FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 8. BADGES TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    badge_key TEXT NOT NULL,
    badge_title TEXT NOT NULL,
    badge_description TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_badge UNIQUE (user_id, badge_key)
);

-- RLS: Badges
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own badges" 
    ON public.badges FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 9. CALENDAR EVENTS TABLE (Read-Only Cache & Keywords)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_id TEXT,
    title TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    detected_load_level TEXT NOT NULL DEFAULT 'light' 
        CHECK (detected_load_level IN ('light', 'medium', 'heavy', 'exam')),
    is_exam BOOLEAN DEFAULT FALSE,
    is_user_override BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Calendar Events
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own calendar events" 
    ON public.calendar_events FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 10. INJURIES TABLE (Injury Guard)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.injuries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body_area TEXT NOT NULL CHECK (body_area IN ('knee', 'ankle', 'lower_back', 'shoulder', 'wrist', 'neck', 'hip', 'foot')),
    severity TEXT NOT NULL CHECK (severity IN ('mild', 'moderate', 'severe')),
    expected_recovery_days INT NOT NULL DEFAULT 7,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    logged_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    recovered_at TIMESTAMPTZ
);

-- RLS: Injuries
ALTER TABLE public.injuries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own injury guards" 
    ON public.injuries FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 11. CYCLE LOGS TABLE (Encrypted Payload for Privacy First)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.cycle_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    encrypted_payload TEXT NOT NULL, -- AES encrypted JSON string on client
    phase_hint TEXT CHECK (phase_hint IN ('menstrual', 'follicular', 'ovulatory', 'luteal', 'unknown')),
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_cycle_log_per_day UNIQUE (user_id, log_date)
);

-- RLS: Cycle Logs
ALTER TABLE public.cycle_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own cycle logs" 
    ON public.cycle_logs FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 12. NOTIFICATION SETTINGS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notification_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    wake_time TEXT NOT NULL DEFAULT '07:30',
    tone TEXT NOT NULL DEFAULT 'friendly' CHECK (tone IN ('friendly', 'calm', 'playful')),
    ai_booster_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    daily_ai_count INT NOT NULL DEFAULT 0,
    last_ai_notification_date DATE,
    fcm_token TEXT,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Notification Settings
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage their own notification settings" 
    ON public.notification_settings FOR ALL 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 13. SUBSCRIPTIONS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'monthly', 'yearly')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'past_due', 'canceled', 'trialing')),
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    razorpay_subscription_id TEXT,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view their own subscriptions" 
    ON public.subscriptions FOR SELECT 
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 14. AFFILIATE PRODUCTS TABLE (Curated, Contextual, Dismissible)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.affiliate_products (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    image_url TEXT,
    affiliate_url TEXT NOT NULL,
    trigger_context TEXT[] NOT NULL DEFAULT '{}', -- e.g. ['high_stress', 'exam_week', 'low_sleep']
    partner_name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Affiliate Products
ALTER TABLE public.affiliate_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users view active affiliate products" 
    ON public.affiliate_products FOR SELECT 
    TO authenticated 
    USING (is_active = true);

-- ==============================================================================
-- 15. AFFILIATE EVENTS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.affiliate_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL REFERENCES public.affiliate_products(id),
    event_type TEXT NOT NULL CHECK (event_type IN ('impression', 'click', 'dismiss')),
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Affiliate Events
ALTER TABLE public.affiliate_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users record their own affiliate events" 
    ON public.affiliate_events FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 16. PARTNER API KEYS TABLE (B2B Standalone Engine)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.partner_api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_name TEXT NOT NULL,
    api_key_hash TEXT NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    requests_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- RLS: Partner API Keys (service role only)
ALTER TABLE public.partner_api_keys ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- USER INITIALIZATION TRIGGER (auto-create profile on signup)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name, created_at, updated_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'Athlete'),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.streaks (user_id, updated_at)
    VALUES (NEW.id, NOW())
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.notification_settings (user_id, updated_at)
    VALUES (NEW.id, NOW())
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.subscriptions (user_id, trial_start, trial_end, updated_at)
    VALUES (NEW.id, NOW(), NOW() + INTERVAL '7 days', NOW())
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
