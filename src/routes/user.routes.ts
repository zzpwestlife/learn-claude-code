import { Router } from 'express';

const router = Router();

// Get current user info
router.get('/me', (req, res) => {
  res.json({ message: 'Get current user endpoint' });
});

// Update user info
router.put('/me', (req, res) => {
  res.json({ message: 'Update user endpoint' });
});

export = router;
