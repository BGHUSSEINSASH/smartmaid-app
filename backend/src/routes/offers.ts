import { Router } from 'express';
import { coupons } from '../store';

const router = Router();

router.get('/', (_req, res) => {
  res.json({ coupons });
});

router.post('/apply', (req, res) => {
  const code = String(req.body?.code ?? '').toUpperCase();
  const total = Number(req.body?.total ?? 0);
  const coupon = coupons.find((c) => c.code === code);
  if (!coupon) {
    res.status(404).json({ message: 'Coupon not found' });
    return;
  }
  if (total < coupon.minTotal) {
    res.status(400).json({ message: `Minimum total is ${coupon.minTotal}` });
    return;
  }
  res.json({
    ...coupon,
    discount: (total * coupon.discountPercent) / 100,
  });
});

export default router;
