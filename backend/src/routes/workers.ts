import { Router } from 'express';
import { workers } from '../store';

const router = Router();

router.get('/search', (_req, res) => {
  res.json(workers);
});

export default router;
