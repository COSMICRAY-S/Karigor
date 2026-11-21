// karigor_backend/routes/auth.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'karigor_khoj_secret_key';

// POST /api/auth/register
router.post('/register', async (req, res) => {
  const { name, phone, email, password, role } = req.body;

  if (!name || !phone || !email || !password || !role) {
    return res.status(400).json({ error: 'সব তথ্য পূরণ করুন' });
  }

  const normalizedEmail = email.trim().toLowerCase();
  const trimmedPhone = phone.trim();

  if (password.length < 4) {
    return res.status(400).json({ error: 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে' });
  }

  if (role !== 'seeker' && role !== 'karigor') {
    return res.status(400).json({ error: 'সঠিক রোল নির্বাচন করুন (seeker অথবা karigor)' });
  }

  const client = await pool.connect();

  try {
    // Check if phone or email already exists
    const exists = await client.query(
      'SELECT id, phone, email FROM users WHERE phone = $1 OR LOWER(email) = $2', 
      [trimmedPhone, normalizedEmail]
    );

    if (exists.rows.length > 0) {
      const row = exists.rows[0];
      if (row.phone === trimmedPhone) {
        return res.status(409).json({ error: 'এই নম্বরে আগেই অ্যাকাউন্ট আছে' });
      } else {
        return res.status(409).json({ error: 'এই ইমেইলে আগেই অ্যাকাউন্ট আছে' });
      }
    }

    const password_hash = await bcrypt.hash(password, 10);

    await client.query('BEGIN');

    const result = await client.query(
      `INSERT INTO users (name, phone, email, role, password_hash)
       VALUES ($1, $2, $3, $4, $5) RETURNING id, name, phone, email, role`,
      [name.trim(), trimmedPhone, normalizedEmail, role, password_hash]
    );

    const user = result.rows[0];

    // If role is 'karigor', create a default profile record
    if (role === 'karigor') {
      await client.query(
        `INSERT INTO karigor_profiles (user_id, service_category, is_verified, is_online, rating, review_count, bio, latitude, longitude)
         VALUES ($1, 'প্লাম্বার', true, true, 5.0, 0, 'নতুন নিবন্ধিত কারিগর। আমার সেবা পেতে যোগাযোগ করুন।', 23.8103, 90.4125)`,
        [user.id]
      );
    }

    await client.query('COMMIT');

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({ user, token });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Registration error:', err);
    res.status(500).json({ error: 'সার্ভার এরর, নিবন্ধন ব্যর্থ হয়েছে' });
  } finally {
    client.release();
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { phone, password, role } = req.body;

  if (!phone || !password) {
    return res.status(400).json({ error: 'ফোন নম্বর ও পাসওয়ার্ড দিন' });
  }

  const trimmedPhone = phone.trim();

  try {
    let query = 'SELECT * FROM users WHERE phone = $1';
    const params = [trimmedPhone];

    if (role) {
      query += ' AND role = $2';
      params.push(role);
    }

    const result = await pool.query(query, params);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'ফোন নম্বর বা পাসওয়ার্ড ভুল' });
    }

    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password_hash);

    if (!isValid) {
      return res.status(401).json({ error: 'ফোন নম্বর বা পাসওয়ার্ড ভুল' });
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...userWithoutPassword } = user;
    res.json({ user: userWithoutPassword, token });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'ইমেইল ও নতুন পাসওয়ার্ড প্রয়োজন' });
  }

  const normalizedEmail = email.trim().toLowerCase();

  if (password.length < 4) {
    return res.status(400).json({ error: 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে' });
  }

  try {
    const userCheck = await pool.query(
      'SELECT id FROM users WHERE LOWER(email) = $1',
      [normalizedEmail]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'এই ইমেইলটি নিবন্ধিত নয়' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE LOWER(email) = $2',
      [password_hash, normalizedEmail]
    );

    res.json({ message: 'পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে' });
  } catch (err) {
    console.error('Forgot-password error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

module.exports = router;
