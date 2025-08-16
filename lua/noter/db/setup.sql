CREATE TABLE IF NOT EXISTS files (
    filepath TEXT PRIMARY KEY,
    filename TEXT NOT NULL UNIQUE,
    lastChecked TEXT NOT NULL
);
