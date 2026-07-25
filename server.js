const express = require('express');
const os = require('os');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de la base de datos PostgreSQL desde variables de entorno
const pool = new Pool({
  host: process.env.DB_HOST || 'database',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'secret123',
  database: process.env.DB_NAME || 'finflow_db',
  port: 5432,
});

app.use(express.json());

// Endpoint principal para verificar balanceo de carga (Round-Robin)
app.get(['/', '/api/'], (req, res) => {
  res.json({
    status: 'success',
    message: '🚀 FinFlow Backend API - Cloud Resiliency Sprint',
    hostname: os.hostname(), // Muestra el ID/Hostname del contenedor replica
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Endpoint de salud
app.get('/api/health', (req, res) => {
  res.json({ status: 'UP', hostname: os.hostname() });
});

// Endpoint para probar conexión a la Base de Datos privada
app.get('/api/db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as current_time, current_database() as db_name;');
    res.json({
      status: 'database connected',
      hostname: os.hostname(),
      db_info: result.rows[0]
    });
  } catch (error) {
    res.status(500).json({
      status: 'database error',
      hostname: os.hostname(),
      error: error.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} - Container Hostname: ${os.hostname()}`);
});
