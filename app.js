const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const { Client } = require('pg');

const dbConfig = {
  user: 'your-db-username', // Replace with your database username
  host: 'your-db-host', // Replace with your RDS endpoint
  database: 'your-db-name', // Replace with your database name
  password: 'your-db-password', // Replace with your database password
  port: 5432 // Replace with your database port
};

const client = new Client(dbConfig);
client.connect();

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
    const result = await client.query('INSERT INTO your_table (data) VALUES ($1)', [JSON.stringify(data)]);
    console.log('Data inserted:', result.rows);
    res.json({ status: 'Data received and stored in RDS' });
  } catch (error) {
    console.error('Error inserting data:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

process.on('SIGINT', () => {
  client.end();
  process.exit();
});
