-- Create products table if it doesn't exist
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL,
    UNIQUE(name)
);

-- Create audit_logs table for tracking all operations
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    event_id VARCHAR(36) NOT NULL UNIQUE,
    event_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT,
    operation VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    user_id VARCHAR(100),
    request_payload TEXT,
    response_payload TEXT,
    error_message TEXT,
    http_status_code INTEGER,
    request_timestamp TIMESTAMP NOT NULL,
    completion_timestamp TIMESTAMP,
    duration_ms BIGINT,
    source_ip VARCHAR(45),
    pod_name VARCHAR(100),
    chaos_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_audit_event_type ON audit_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_audit_entity_id ON audit_logs(entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_status ON audit_logs(status);
CREATE INDEX IF NOT EXISTS idx_audit_operation ON audit_logs(operation);
CREATE INDEX IF NOT EXISTS idx_audit_request_timestamp ON audit_logs(request_timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_chaos_active ON audit_logs(chaos_active);
