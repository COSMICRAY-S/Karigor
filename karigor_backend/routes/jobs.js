// karigor_backend/routes/jobs.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// POST /api/jobs — job request পাঠানো
router.post('/', async (req, res) => {
  const { seeker_id, karigor_id, description, location, amount } = req.body;

  if (!seeker_id || !karigor_id || !description) {
    return res.status(400).json({ error: 'সব তথ্য দিন (seeker_id, karigor_id, description)' });
  }

  const numAmount = parseFloat(amount) || 0;

  try {
    const result = await pool.query(
      `INSERT INTO job_requests (seeker_id, karigor_id, description, location, status, amount)
       VALUES ($1, $2, $3, $4, 'pending', $5)
       RETURNING *`,
      [seeker_id, karigor_id, description.trim(), location ? location.trim() : '', numAmount]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Job request error:', err);
    res.status(500).json({ error: 'সার্ভার এরর, অনুরোধ পাঠানো সম্ভব হয়নি' });
  }
});

// GET /api/jobs/karigor/:id — karigor এর সব job দেখো
router.get('/karigor/:id', async (req, res) => {
  const karigorId = parseInt(req.params.id, 10);
  if (isNaN(karigorId)) {
    return res.status(400).json({ error: 'সঠিক আইডি দিন' });
  }

  try {
    const result = await pool.query(
      `SELECT 
        j.id, j.seeker_id, j.karigor_id, j.description, j.location, j.status, j.created_at, j.amount,
        u.name AS seeker_name, u.phone AS seeker_phone
       FROM job_requests j
       JOIN users u ON j.seeker_id = u.id
       WHERE j.karigor_id = $1
       ORDER BY j.created_at DESC`,
      [karigorId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Karigor jobs error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/jobs/seeker/:id — seeker এর সব job দেখো
router.get('/seeker/:id', async (req, res) => {
  const seekerId = parseInt(req.params.id, 10);
  if (isNaN(seekerId)) {
    return res.status(400).json({ error: 'সঠিক আইডি দিন' });
  }

  try {
    const result = await pool.query(
      `SELECT 
        j.id, j.seeker_id, j.karigor_id, j.description, j.location, j.status, j.created_at, j.amount,
        u.name AS karigor_name, u.phone AS karigor_phone
       FROM job_requests j
       JOIN users u ON j.karigor_id = u.id
       WHERE j.seeker_id = $1
       ORDER BY j.created_at DESC`,
      [seekerId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Seeker jobs error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// PUT /api/jobs/:id/status — accept, reject, বা completed করো
router.put('/:id/status', async (req, res) => {
  const jobId = parseInt(req.params.id, 10);
  const { status } = req.body; // 'accepted', 'rejected', 'completed'

  if (isNaN(jobId)) {
    return res.status(400).json({ error: 'সঠিক জব আইডি দিন' });
  }

  if (!status || !['pending', 'accepted', 'rejected', 'completed'].includes(status)) {
    return res.status(400).json({ error: 'সঠিক স্ট্যাটাস দিন (accepted, rejected, completed)' });
  }

  try {
    const result = await pool.query(
      `UPDATE job_requests SET status = $1 WHERE id = $2 RETURNING *`,
      [status, jobId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'কাজের অনুরোধটি পাওয়া যায়নি' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Job status update error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

module.exports = router;
