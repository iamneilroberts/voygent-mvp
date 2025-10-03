-- Voygent Database Schema
-- Logging and telemetry for LLM sessions

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Session tracking table
CREATE TABLE IF NOT EXISTS llm_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  mode TEXT DEFAULT 'general',  -- 'travel_agent', 'general', etc.
  model TEXT,                   -- e.g., 'claude-3-5-sonnet-20241022'
  provider TEXT,                -- 'anthropic', 'openai', etc.
  total_tokens_in INT DEFAULT 0,
  total_tokens_out INT DEFAULT 0,
  total_cost_usd NUMERIC(10,6) DEFAULT 0,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Message tracking table with full telemetry
CREATE TABLE IF NOT EXISTS llm_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES llm_sessions(id) ON DELETE CASCADE,
  role TEXT CHECK (role IN ('system', 'user', 'assistant', 'tool')),
  content TEXT,
  tokens_in INT DEFAULT 0,
  tokens_out INT DEFAULT 0,
  cost_usd NUMERIC(10,6) DEFAULT 0,
  latency_ms INT,               -- Response time in milliseconds
  provider TEXT,                -- LLM provider used for this message
  model TEXT,                   -- Model used for this message
  created_at TIMESTAMPTZ DEFAULT NOW(),
  tool_name TEXT,               -- If role='tool', which tool was called
  tool_payload JSONB,           -- Tool input/output
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Trip index for semantic + keyword search
CREATE TABLE IF NOT EXISTS trip_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  title TEXT NOT NULL,
  summary TSVECTOR,             -- Full-text search
  embedding VECTOR(1536),       -- Semantic embeddings (OpenAI/Anthropic dimensions)
  destinations TEXT[],          -- Array of destination names
  start_date DATE,
  end_date DATE,
  budget_usd NUMERIC(10,2),
  tags TEXT[],
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_llm_sessions_user_id ON llm_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_llm_sessions_started_at ON llm_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_llm_messages_session_id ON llm_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_llm_messages_created_at ON llm_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_trip_index_user_id ON trip_index(user_id);
CREATE INDEX IF NOT EXISTS idx_trip_index_summary ON trip_index USING GIN(summary);
CREATE INDEX IF NOT EXISTS idx_trip_index_embedding ON trip_index USING ivfflat(embedding vector_cosine_ops);

-- Trigger to auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_llm_sessions_updated_at
  BEFORE UPDATE ON llm_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trip_index_updated_at
  BEFORE UPDATE ON trip_index
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to update session totals
CREATE OR REPLACE FUNCTION update_session_totals()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE llm_sessions
  SET
    total_tokens_in = (
      SELECT COALESCE(SUM(tokens_in), 0)
      FROM llm_messages
      WHERE session_id = NEW.session_id
    ),
    total_tokens_out = (
      SELECT COALESCE(SUM(tokens_out), 0)
      FROM llm_messages
      WHERE session_id = NEW.session_id
    ),
    total_cost_usd = (
      SELECT COALESCE(SUM(cost_usd), 0)
      FROM llm_messages
      WHERE session_id = NEW.session_id
    )
  WHERE id = NEW.session_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_session_totals_on_message
  AFTER INSERT OR UPDATE ON llm_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_session_totals();

-- Function to generate tsvector from trip title
CREATE OR REPLACE FUNCTION update_trip_summary()
RETURNS TRIGGER AS $$
BEGIN
  NEW.summary = to_tsvector('english', COALESCE(NEW.title, '') || ' ' || COALESCE(array_to_string(NEW.destinations, ' '), ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trip_summary_trigger
  BEFORE INSERT OR UPDATE ON trip_index
  FOR EACH ROW
  EXECUTE FUNCTION update_trip_summary();

-- Sample data (optional - for testing)
-- Uncomment to insert sample data

/*
INSERT INTO llm_sessions (user_id, mode, model, provider) VALUES
  ('00000000-0000-0000-0000-000000000001', 'travel_agent', 'claude-3-5-sonnet-20241022', 'anthropic');

INSERT INTO llm_messages (session_id, role, content, tokens_in, tokens_out, cost_usd, latency_ms)
SELECT id, 'user', 'Plan a trip to Paris', 10, 0, 0, 0
FROM llm_sessions LIMIT 1;

INSERT INTO trip_index (user_id, title, destinations, start_date, end_date, budget_usd, tags) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Romantic Paris Getaway', ARRAY['Paris', 'Versailles'], '2025-06-01', '2025-06-07', 3000, ARRAY['romantic', 'culture', 'food']);
*/
