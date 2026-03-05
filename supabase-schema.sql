-- ================================================================
-- MARKET CIPHER RISK SIMULATOR — SUPABASE SCHEMA
-- Run this entire file in: Supabase Dashboard → SQL Editor → New Query
-- Created for: Alauddin Ahmed
-- ================================================================


-- ── TABLE 1: risk_months ────────────────────────────────────────
-- Stores each user's monthly W/L trade sequences

CREATE TABLE IF NOT EXISTS risk_months (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name        TEXT NOT NULL,
  seq         TEXT NOT NULL,
  added       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security: users can only see/edit their own months
ALTER TABLE risk_months ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own months"
  ON risk_months FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own months"
  ON risk_months FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own months"
  ON risk_months FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users delete own months"
  ON risk_months FOR DELETE USING (auth.uid() = user_id);


-- ── TABLE 2: risk_scenarios ─────────────────────────────────────
-- Stores each user's custom scenario configurations (JSON)

CREATE TABLE IF NOT EXISTS risk_scenarios (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  scenarios   JSONB,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE risk_scenarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own scenarios"
  ON risk_scenarios FOR ALL USING (auth.uid() = user_id);


-- ── TABLE 3: risk_leaderboard ───────────────────────────────────
-- Stores publicly published simulation results for the leaderboard

CREATE TABLE IF NOT EXISTS risk_leaderboard (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  user_name         TEXT NOT NULL,
  month_name        TEXT NOT NULL,
  return_pct        NUMERIC,
  max_dd            NUMERIC,
  final_balance     NUMERIC,
  trades            INTEGER,
  starting_capital  NUMERIC,
  scenario_label    TEXT,
  scenario_config   TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE risk_leaderboard ENABLE ROW LEVEL SECURITY;

-- Anyone logged in can READ the leaderboard
CREATE POLICY "Anyone reads leaderboard"
  ON risk_leaderboard FOR SELECT TO authenticated USING (TRUE);

-- Users can only INSERT their own results
CREATE POLICY "Users insert own results"
  ON risk_leaderboard FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can delete their own leaderboard entries
CREATE POLICY "Users delete own entries"
  ON risk_leaderboard FOR DELETE USING (auth.uid() = user_id);


-- ================================================================
-- DONE! All 3 tables created with security policies.
-- ================================================================
