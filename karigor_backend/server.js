// karigor_backend/server.js
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const providerRoutes = require('./routes/providers');
const jobRoutes = require('./routes/jobs');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/jobs', jobRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'Karigor Khoj API চালু আছে ✅', version: '1.0' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'রুট পাওয়া যায়নি (404 Not Found)' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({ error: 'সার্ভার অভ্যন্তরীণ ত্রুটি (Internal Server Error)' });
});

app.listen(PORT, () => {
  console.log(`✅ Server চালু হয়েছে: http://localhost:${PORT}`);
});
