// karigor_backend/routes/auth.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL ||
    'postgresql://postgres:password@localhost:5432/karigor_khoj',
});

const JWT_SECRET = process.env.JWT_SECRET || 'karigor_khoj_secret_key';

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { name, phone, email, password, role } = req.body;

  if (!name || !phone || !email || !password || !role) {
    return res.status(400).json({ error: 'সব তথ্য প্রয়োজন' });
  }

  if (password.length < 4) {
    return res.status(400).json({ error: 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে' });
  }

  try {
    // Check if phone or email already exists
    const exists = await pool.query(
      'SELECT id, phone, email FROM users WHERE phone = $1 OR email = $2', 
      [phone, email]
    );
    if (exists.rows.length > 0) {
      const row = exists.rows[0];
      if (row.phone === phone) {
        return res.status(409).json({ error: 'এই নম্বরে আগেই অ্যাকাউন্ট আছে' });
      } else {
        return res.status(409).json({ error: 'এই ইমেইলে আগেই অ্যাকাউন্ট আছে' });
      }
    }

    const password_hash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (name, phone, email, role, password_hash)
       VALUES ($1, $2, $3, $4, $5) RETURNING id, name, phone, email, role`,
      [name, phone, email, role, password_hash]
    );

    const user = result.rows[0];

    // If role is 'karigor', create a default profile record
    if (role === 'karigor') {
      await pool.query(
        `INSERT INTO karigor_profiles (user_id, service_category, is_verified, is_online, rating, review_count, bio, latitude, longitude)
         VALUES ($1, 'প্লাম্বার', true, true, 5.0, 0, 'নতুন নিবন্ধিত কারিগর। আমার সেবা পেতে যোগাযোগ করুন।', 23.8103, 90.4125)`,
        [user.id]
      );
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({ user, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { phone, password, role } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE phone = $1 AND role = $2',
      [phone, role]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'ফোন নম্বর বা পাসওয়ার্ড ভুল' });
    }

    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password_hash);

    if (!isValid) {
      return res.status(401).json({ error: 'পাসওয়ার্ড ভুল' });
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...userWithoutPassword } = user;
    res.json({ user: userWithoutPassword, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'ইমেইল ও নতুন পাসওয়ার্ড প্রয়োজন' });
  }

  if (password.length < 4) {
    return res.status(400).json({ error: 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে' });
  }

  try {
    const userCheck = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'এই ইমেইলটি নিবন্ধিত নয়' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    await pool.query('UPDATE users SET password_hash = $1 WHERE email = $2', [password_hash, email]);

    res.json({ message: 'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

module.exports = router;
