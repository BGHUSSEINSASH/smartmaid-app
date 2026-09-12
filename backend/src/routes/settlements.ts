import { Router } from 'express';
import { requireAuth } from '../middleware/auth';

const router = Router();

const settlements: Map<string, {
  workerId: string;
  month: string;
  totalEarnings: number;
  platformFee: number;
  netPayout: number;
  bookingsCount: number;
  settledAt: Date;
}> = new Map();

// Seed demo data
const demoWorkerId = 'cw1';
const now = new Date();
for (let i = 0; i < 3; i++) {
  const d = new Date(now);
  d.setMonth(d.getMonth() - i);
  const key = `${demoWorkerId}_${d.toISOString().slice(0, 7)}`;
  const total = 1200 + Math.round(Math.random() * 600);
  const fee = Math.round(total * 0.20);
  settlements.set(key, {
    workerId: demoWorkerId,
    month: d.toISOString().slice(0, 7),
    totalEarnings: total,
    platformFee: fee,
    netPayout: total - fee,
    bookingsCount: 8 + i * 2,
    settledAt: new Date(d.getFullYear(), d.getMonth() + 1, 0),
  });
}

router.get('/:month', requireAuth, (req: any, res) => {
  const { month } = req.params;
  const workerId = req.user.id;
  const key = `${workerId}_${month}`;
  const record = settlements.get(key);

  if (!record) {
    return res.json({
      month,
      totalEarnings: 0,
      platformFee: 0,
      netPayout: 0,
      bookingsCount: 0,
      settled: false,
    });
  }

  res.json({
    ...record,
    settled: true,
  });
});

router.get('/history', requireAuth, (req: any, res) => {
  const workerId = req.user.id;
  const records = Array.from(settlements.values())
    .filter((s) => s.workerId === workerId)
    .sort((a, b) => b.month.localeCompare(a.month));
  res.json({ records, total: records.length });
});

export default router;
