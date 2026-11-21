// karigor_backend/routes/providers.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// GET /api/providers
router.get('/', async (req, res) => {
  const { category, lat, lng, radius } = req.query;
  const userLat = parseFloat(lat);
  const userLng = parseFloat(lng);
  const maxKm = parseFloat(radius) || 5; // default 5 km

  try {
    const params = [];
    let paramIdx = 1;

    const hasUserLocation = !isNaN(userLat) && !isNaN(userLng);

    // Build safe distance expression (Haversine formula in SQL)
    // Uses LEAST(1.0, GREATEST(-1.0, ...)) to prevent acos domain errors on identical/near coordinates
    let distanceExpr = '0.0';

    if (hasUserLocation) {
      const latIdx = paramIdx++;
      const lngIdx = paramIdx++;
      params.push(userLat, userLng);

      distanceExpr = `(
        6371 * acos(
          LEAST(1.0, GREATEST(-1.0,
            cos(radians($${latIdx})) * cos(radians(k.latitude)) *
            cos(radians(k.longitude) - radians($${lngIdx})) +
            sin(radians($${latIdx})) * sin(radians(k.latitude))
          ))
        )
      )`;
    }

    let query = `
      SELECT 
        u.id, u.name, u.phone,
        COALESCE(k.service_category, 'সাধারণ') AS category,
        COALESCE(k.is_verified, false) AS is_verified,
        COALESCE(k.is_online, false) AS is_online,
        COALESCE(k.rating, 5.0) AS rating,
        COALESCE(k.review_count, 0) AS review_count,
        COALESCE(k.bio, '') AS bio,
        k.latitude, k.longitude,
        ROUND(COALESCE(${distanceExpr}, 0.0)::numeric, 2) AS distance
      FROM users u
      JOIN karigor_profiles k ON u.id = k.user_id
      WHERE u.role = 'karigor'
    `;

    if (category && category.trim() !== '' && category.trim() !== 'সব') {
      params.push(`%${category.trim()}%`);
      query += ` AND k.service_category ILIKE $${paramIdx++}`;
    }

    // Filter by radius only when seeker location is known and providers have a location set
    if (hasUserLocation) {
      params.push(maxKm);
      const radiusParamIdx = paramIdx++;

      query += `
        AND k.latitude IS NOT NULL AND k.longitude IS NOT NULL
        AND (
          6371 * acos(
            LEAST(1.0, GREATEST(-1.0,
              cos(radians($1)) * cos(radians(k.latitude)) *
              cos(radians(k.longitude) - radians($2)) +
              sin(radians($1)) * sin(radians(k.latitude))
            ))
          )
        ) <= $${radiusParamIdx}
      `;
    }

    query += ' ORDER BY k.is_online DESC, distance ASC, k.rating DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Providers fetch error:', err);
    res.status(500).json({ error: 'সার্ভার এরর, কারিগরদের তালিকা পাওয়া যায়নি' });
  }
});

// PUT /api/providers/status — online status update
router.put('/status', async (req, res) => {
  const { provider_id, is_online } = req.body;
  if (!provider_id || is_online === undefined) {
    return res.status(400).json({ error: 'provider_id ও is_online প্রয়োজন' });
  }
  try {
    const result = await pool.query(
      'UPDATE karigor_profiles SET is_online = $1 WHERE user_id = $2 RETURNING user_id, is_online',
      [Boolean(is_online), provider_id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'প্রোফাইল পাওয়া যায়নি' });
    }
    res.json({ message: 'অনলাইন স্ট্যাটাস আপডেট করা হয়েছে', is_online: result.rows[0].is_online });
  } catch (err) {
    console.error('Status update error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// PUT /api/providers/location — GPS location update
router.put('/location', async (req, res) => {
  const { provider_id, latitude, longitude } = req.body;
  if (!provider_id || latitude === undefined || longitude === undefined) {
    return res.status(400).json({ error: 'provider_id, latitude এবং longitude প্রয়োজন' });
  }
  try {
    const result = await pool.query(
      'UPDATE karigor_profiles SET latitude = $1, longitude = $2 WHERE user_id = $3 RETURNING user_id, latitude, longitude',
      [parseFloat(latitude), parseFloat(longitude), provider_id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'প্রোফাইল পাওয়া যায়নি' });
    }
    res.json({ message: 'অবস্থান সফলভাবে আপডেট করা হয়েছে', location: result.rows[0] });
  } catch (err) {
    console.error('Location update error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// PUT /api/providers/profile — update bio and service_category
router.put('/profile', async (req, res) => {
  const { provider_id, service_category, bio } = req.body;
  if (!provider_id) {
    return res.status(400).json({ error: 'provider_id প্রয়োজন' });
  }
  try {
    const result = await pool.query(
      `UPDATE karigor_profiles 
       SET service_category = COALESCE($1, service_category), 
           bio = COALESCE($2, bio) 
       WHERE user_id = $3
       RETURNING user_id, service_category, bio`,
      [service_category ? service_category.trim() : null, bio ? bio.trim() : null, provider_id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'প্রোফাইল পাওয়া যায়নি' });
    }
    res.json({ message: 'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে', profile: result.rows[0] });
  } catch (err) {
    console.error('Profile update error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/providers/:id
router.get('/:id', async (req, res) => {
  const providerId = parseInt(req.params.id, 10);
  if (isNaN(providerId)) {
    return res.status(400).json({ error: 'সঠিক আইডি দিন' });
  }

  try {
    const result = await pool.query(
      `SELECT 
        u.id, u.name, u.phone,
        COALESCE(k.service_category, 'সাধারণ') AS category,
        COALESCE(k.is_verified, false) AS is_verified,
        COALESCE(k.is_online, false) AS is_online,
        COALESCE(k.rating, 5.0) AS rating,
        COALESCE(k.review_count, 0) AS review_count,
        COALESCE(k.bio, '') AS bio,
        k.latitude, k.longitude,
        0.0 AS distance
      FROM users u
      LEFT JOIN karigor_profiles k ON u.id = k.user_id
      WHERE u.id = $1`,
      [providerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'কারিগর পাওয়া যায়নি' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Provider fetch error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// GET /api/providers/:id/reviews
router.get('/:id/reviews', async (req, res) => {
  const providerId = parseInt(req.params.id, 10);
  if (isNaN(providerId)) {
    return res.status(400).json({ error: 'সঠিক আইডি দিন' });
  }

  try {
    const result = await pool.query(
      `SELECT r.rating, r.comment, r.created_at, u.name AS seeker_name
       FROM reviews r
       JOIN users u ON r.seeker_id = u.id
       WHERE r.karigor_id = $1
       ORDER BY r.created_at DESC`,
       [providerId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Reviews fetch error:', err);
    res.status(500).json({ error: 'সার্ভার এরর' });
  }
});

// POST /api/providers/:id/reviews
router.post('/:id/reviews', async (req, res) => {
  const { seeker_id, rating, comment } = req.body;
  const karigor_id = parseInt(req.params.id, 10);

  if (!seeker_id || !rating || !comment || isNaN(karigor_id) || karigor_id <= 0) {
    return res.status(400).json({ error: 'সব তথ্য দিন (seeker_id, rating, comment ও সঠিক karigor_id)' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Insert review
    await client.query(
      `INSERT INTO reviews (seeker_id, karigor_id, rating, comment, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [seeker_id, karigor_id, rating, comment.trim()]
    );

    // 2. Recalculate average rating & review count for the provider
    const reviewStats = await client.query(
      `SELECT COUNT(*)::int AS count, AVG(rating)::numeric(3,2) AS avg_rating 
       FROM reviews 
       WHERE karigor_id = $1`,
      [karigor_id]
    );

    const { count, avg_rating } = reviewStats.rows[0];

    // 3. Update karigor_profiles
    await client.query(
      `UPDATE karigor_profiles 
       SET rating = $1, review_count = $2 
       WHERE user_id = $3`,
      [avg_rating || 5.0, count || 0, karigor_id]
    );

    await client.query('COMMIT');
    res.status(201).json({ message: 'রিভিউ সফলভাবে যোগ করা হয়েছে' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Review submit error:', err);
    res.status(500).json({ error: 'সার্ভার এরর, রিভিউ যোগ করা যায়নি' });
  } finally {
    client.release();
  }
});

module.exports = router;
