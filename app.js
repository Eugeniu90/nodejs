const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const { Client } = require('pg');

const dbConfig = {
  user: 'postgres', // Replace with your database username
  host: 'default-poc-1.c8or4ndxnhjc.eu-west-1.rds.amazonaws.com', // Replace with your RDS endpoint
  database: 'postgres', // Replace with your database name
  password: 'lZS6clY{1p.8', // Replace with your database password
  port: 5432 // Replace with your database port
};

const client = new Client(dbConfig);

client.connect(err => {
  if (err) {
    console.error('Connection error', err.stack);
  } else {
    console.log('Connected to database');
  }
});

// Body parser middleware
app.use(bodyParser.json());

// GET /status
app.get('/status', (req, res) => {
  res.json({ status: 'Application is running' });
});

// POST /data
app.post('/data', async (req, res) => {
  const data = req.body;

  try {
    const result = await client.query('INSERT INTO postgres (data) VALUES ($1) RETURNING *', [data]);
    console.log('Data inserted:', result.rows[0]);
    res.json({ status: 'Data received and stored in PostgreSQL', insertedData: result.rows[0] });
  } catch (error) {
    console.error('Error inserting data:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

process.on('SIGINT', () => {
  client.end();
  process.exit();
});
