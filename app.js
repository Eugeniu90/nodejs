const express = require('express');
const bodyParser = require('body-parser');
const app = express();

// Body parser middleware
app.use(bodyParser.json());

// Database (Example: In-memory database)
const db = [];

// GET /status
app.get('/status', (req, res) => {
  res.json({ status: 'Application is running' });
});

// POST /data
app.post('/data', (req, res) => {
  db.push(req.body);
  res.json({ status: 'Data received' });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
