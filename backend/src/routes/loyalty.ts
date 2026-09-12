import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, AuthedRequest } from '../middleware/auth';
import { loyaltyByUser } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const record =
    loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  const tier = record.points >= 1500 ? 'gold' : record.points >= 500 ? 'silver' : 'bronze';
  res.json({ ...record, tier, pointsPerUsdRedeem: 20 });
});

router.post('/earn', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({ points: z.number().int().positive(), title: z.string().min(1) });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const record = loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  record.points += parsed.data.points;
  record.history.unshift({
    title: parsed.data.title,
    points: parsed.data.points,
    at: new Date().toISOString(),
  });
  loyaltyByUser.set(req.user!.id, record);
  res.json(record);
});

router.post('/redeem', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({ discountUsd: z.number().positive() });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload' });
    return;
  }
  const cost = Math.round(parsed.data.discountUsd * 20);
  const record = loyaltyByUser.get(req.user!.id);
  if (!record || cost > record.points) {
    res.status(400).json({ message: 'Not enough points' });
    return;
  }
  record.points -= cost;
  record.history.unshift({
    title: `استبدال بخصم $${parsed.data.discountUsd}`,
    points: -cost,
    at: new Date().toISOString(),
  });
  res.json(record);
});

export default router;
