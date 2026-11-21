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

app.listen(PORT, () => {
  console.log(`✅ Server চালু হয়েছে: http://localhost:${PORT}`);
});