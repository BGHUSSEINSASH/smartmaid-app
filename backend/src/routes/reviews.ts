import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, AuthedRequest } from '../middleware/auth';
import { reviews } from '../store';

const router = Router();

router.get('/worker/:workerId', (req, res) => {
  const list = reviews
    .filter((r) => r.workerId === req.params.workerId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  const average =
    list.length > 0 ? list.reduce((s, r) => s + r.rating, 0) / list.length : 0;
  res.json({ reviews: list, average, count: list.length });
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({
    workerId: z.string().min(1),
    rating: z.number().min(1).max(5),
    comment: z.string().min(1),
  });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const review = {
    id: `r_${Date.now()}`,
    workerId: parsed.data.workerId,
    userId: req.user!.id,
    rating: parsed.data.rating,
    comment: parsed.data.comment,
    createdAt: new Date().toISOString(),
  };
  reviews.push(review);
  res.status(201).json(review);
});

export default router;
