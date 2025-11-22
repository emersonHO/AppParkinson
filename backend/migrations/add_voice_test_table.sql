-- Migración para agregar la tabla voice_tests
-- Ejecutar este script si Flask-Migrate no detecta automáticamente el cambio

CREATE TABLE IF NOT EXISTS voice_test (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id VARCHAR(100) NOT NULL,
    date VARCHAR(50) NOT NULL,
    probability REAL NOT NULL,
    level VARCHAR(50) NOT NULL,
    fo REAL,
    fhi REAL,
    flo REAL,
    jitter_percent REAL,
    jitter_abs REAL,
    rap REAL,
    ppq REAL,
    ddp REAL,
    shimmer REAL,
    shimmer_db REAL,
    apq3 REAL,
    apq5 REAL,
    apq REAL,
    dda REAL,
    nhr REAL,
    hnr REAL,
    rpde REAL,
    dfa REAL,
    spread1 REAL,
    spread2 REAL,
    d2 REAL,
    ppe REAL
);





