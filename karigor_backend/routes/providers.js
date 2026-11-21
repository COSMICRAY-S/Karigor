const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// GET /api/providers
router.get('/', async (req, res) => {
  const { category, lat, lng, radius } = req.query;
  const userLat = parseFloat(lat);
  const userLng = parseFloat(lng);
  const maxKm = parseFloat(radius) || 5; // default 5 km

  try {
    const params = [];
    let paramIdx = 1;

    // Build distance expression (Haversine formula in SQL)
    // Returns km. When no lat/lng provided, returns 0.0
    const distanceExpr = (!isNaN(userLat) && !isNaN(userLng))
      ? `(
          6371 * acos(
            cos(radians($${paramIdx++})) * cos(radians(k.latitude)) *
            cos(radians(k.longitude) - radians($${paramIdx++})) +
            sin(radians($${paramIdx - 2})) * sin(radians(k.latitude))
          )
        )`
      : '0.0';

    if (!isNaN(userLat) && !isNaN(userLng)) {
      params.push(userLat, userLng);
    }

    let query = `
      SELECT 
        u.id, u.name, u.phone,
        k.service_category AS category,
        k.is_verified, k.is_online,
        k.rating, k.review_count,
        k.bio, k.latitude, k.longitude,
        ROUND((${distanceExpr})::numeric, 2) AS distance
      FROM users u
      JOIN karigor_profiles k ON u.id = k.user_id
      WHERE u.role = 'karigor'
    `;

    if (category) {
      params.push(`%${category}%`);
      query += ` AND k.service_category ILIKE $${paramIdx++}`;
    }

    // Filter by radius only when seeker location is known and providers have a location set
    if (!isNaN(userLat) && !isNaN(userLng)) {
      query += `
        AND k.latitude IS NOT NULL AND k.longitude IS NOT NULL
        AND (
          6371 * acos(
            cos(radians($1)) * cos(radians(k.latitude)) *
            cos(radians(k.longitude) - radians($2)) +
            sin(radians($1)) * sin(radians(k.latitude))
          )
        ) <= ${maxKm}
      `;
    }

    query += ' ORDER BY k.is_online DESC, distance ASC, k.rating DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});


// PUT /api/providers/status — online status update
router.put('/status', async (req, res) => {
  const { provider_id, is_online } = req.body;
  if (!provider_id || is_online === undefined) {
    return res.status(400).json({ error: 'সব তথ্য দিন' });
  }
  try {
    await pool.query(
      'UPDATE karigor_profiles SET is_online = $1 WHERE user_id = $2',
      [is_online, provider_id]
    );
    res.json({ message: 'অনলাইন স্ট্যাটাস আপডেট করা হয়েছে' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// PUT /api/providers/location — GPS location update
router.put('/location', async (req, res) => {
  const { provider_id, latitude, longitude } = req.body;
  if (!provider_id || latitude === undefined || longitude === undefined) {
    return res.status(400).json({ error: 'সব তথ্য দিন' });
  }
  try {
    await pool.query(
      'UPDATE karigor_profiles SET latitude = $1, longitude = $2 WHERE user_id = $3',
      [latitude, longitude, provider_id]
    );
    res.json({ message: 'অবস্থান সফলভাবে আপডেট করা হয়েছে' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/providers/:id
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        u.id, u.name, u.phone,
        k.service_category AS category,
        k.is_verified, k.is_online,
        k.rating, k.review_count,
        k.bio, k.latitude, k.longitude,
        0.0 AS distance
      FROM users u
      JOIN karigor_profiles k ON u.id = k.user_id
      WHERE u.id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'কারিগর পাওয়া যায়নি' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/providers/:id/reviews
router.get('/:id/reviews', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT r.rating, r.comment, r.created_at, u.name AS seeker_name
       FROM reviews r
       JOIN users u ON r.seeker_id = u.id
       WHERE r.karigor_id = $1
       ORDER BY r.created_at DESC`,
       [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// POST /api/providers/:id/reviews
router.post('/:id/reviews', async (req, res) => {
  const { seeker_id, rating, comment } = req.body;
  const karigor_id = req.params.id;

  if (!seeker_id || !rating || !comment) {
    return res.status(400).json({ error: 'সব তথ্য দিন' });
  }

  try {
    // 1. Insert review
    await pool.query(
      `INSERT INTO reviews (seeker_id, karigor_id, rating, comment, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [seeker_id, karigor_id, rating, comment]
    );

    // 2. Recalculate average rating & review count for the provider
    const reviewStats = await pool.query(
      `SELECT COUNT(*)::int AS count, AVG(rating)::numeric(3,2) AS avg_rating 
       FROM reviews 
       WHERE karigor_id = $1`,
      [karigor_id]
    );

    const { count, avg_rating } = reviewStats.rows[0];

    // 3. Update karigor_profiles
    await pool.query(
      `UPDATE karigor_profiles 
       SET rating = $1, review_count = $2 
       WHERE user_id = $3`,
      [avg_rating || 0.0, count || 0, karigor_id]
    );

    res.status(201).json({ message: 'রিভিউ সফলভাবে যোগ করা হয়েছে' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

module.exports = router;