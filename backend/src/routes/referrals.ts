import { Router } from 'express';
import { requireAuth, AuthedRequest } from '../middleware/auth';
import { loyaltyByUser } from '../store';

const router = Router();

router.get('/me', requireAuth, (req: AuthedRequest, res) => {
  const code = `SMART-${(req.user!.name.split(' ')[0] ?? '').toUpperCase()}-${req.user!.id.slice(-4).toUpperCase()}`;
  res.json({ code });
});

router.post('/apply', requireAuth, (req: AuthedRequest, res) => {
  const code = String(req.body?.code ?? '');
  if (!code.startsWith('SMART-')) {
    res.status(400).json({ message: 'Invalid referral code' });
    return;
  }
  const record =
    loyaltyByUser.get(req.user!.id) ?? { points: 0, history: [] };
  record.points += 100;
  record.history.unshift({
    title: '+100 نقطة من إحالة صديق',
    points: 100,
    at: new Date().toISOString(),
  });
  loyaltyByUser.set(req.user!.id, record);
  res.json({ message: 'Referral applied', points: record.points });
});

export default router;
