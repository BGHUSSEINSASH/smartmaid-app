import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole, AuthedRequest } from '../middleware/auth';
import { walletTransactions } from '../store';

const router = Router();

router.get('/', requireAuth, (req: AuthedRequest, res) => {
  const userId = req.user!.id;
  const txs = walletTransactions
    .filter((t) => t.userId === userId)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  const balance = txs.reduce((sum, t) => sum + t.amount, 0);
  res.json({ balance, transactions: txs });
});

router.post('/topup', requireAuth, (req: AuthedRequest, res) => {
  const schema = z.object({ amount: z.number().positive() });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid amount' });
    return;
  }
  walletTransactions.push({
    id: `t_${Date.now()}`,
    userId: req.user!.id,
    title: 'شحن المحفظة',
    amount: parsed.data.amount,
    type: 'topup',
    createdAt: new Date().toISOString(),
  });
  res.status(201).json({ message: 'Wallet topped up' });
});

router.post(
  '/withdraw',
  requireAuth,
  requireRole('worker', 'admin'),
  (req: AuthedRequest, res) => {
    const schema = z.object({ amount: z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ message: 'Invalid amount' });
      return;
    }
    walletTransactions.push({
      id: `t_${Date.now()}`,
      userId: req.user!.id,
      title: 'طلب سحب أرباح',
      amount: -parsed.data.amount,
      type: 'withdrawal',
      createdAt: new Date().toISOString(),
    });
    res.status(201).json({ message: 'Withdrawal requested' });
  },
);

export default router;
