const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// POST /api/jobs — job request পাঠানো
router.post('/', async (req, res) => {
  const { seeker_id, karigor_id, description, location, amount } = req.body;

  if (!seeker_id || !karigor_id || !description) {
    return res.status(400).json({ error: 'সব তথ্য দিন' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO job_requests (seeker_id, karigor_id, description, location, status, amount)
       VALUES ($1, $2, $3, $4, 'pending', $5)
       RETURNING *`,
      [seeker_id, karigor_id, description, location, amount || 0]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/jobs/karigor/:id — karigor এর সব job দেখো
router.get('/karigor/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        j.id, j.description, j.location, j.status, j.created_at, j.amount,
        u.name AS seeker_name, u.phone AS seeker_phone
       FROM job_requests j
       JOIN users u ON j.seeker_id = u.id
       WHERE j.karigor_id = $1
       ORDER BY j.created_at DESC`,
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/jobs/seeker/:id — seeker এর সব job দেখো
router.get('/seeker/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        j.id, j.description, j.location, j.status, j.created_at, j.amount,
        u.name AS karigor_name, u.phone AS karigor_phone
       FROM job_requests j
       JOIN users u ON j.karigor_id = u.id
       WHERE j.seeker_id = $1
       ORDER BY j.created_at DESC`,
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// PUT /api/jobs/:id/status — accept বা reject করো
router.put('/:id/status', async (req, res) => {
  const { status } = req.body; // 'accepted', 'rejected', 'completed'

  try {
    const result = await pool.query(
      `UPDATE job_requests SET status = $1 WHERE id = $2 RETURNING *`,
      [status, req.params.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

module.exports = router;