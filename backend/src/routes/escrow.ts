import { Router } from 'express';
import { requireAuth } from '../middleware/auth';

const router = Router();

const escrowHolds: Map<string, {
  bookingId: string;
  amount: number;
  status: 'held' | 'released' | 'refunded';
  heldAt: Date;
  releasedAt?: Date;
}> = new Map();

router.post('/hold', requireAuth, (req: any, res) => {
  try {
    const { bookingId, amount } = req.body;
    if (!bookingId || !amount || amount <= 0) {
      return res.status(400).json({ error: 'بيانات غير صحيحة' });
    }
    if (escrowHolds.has(bookingId)) {
      return res.status(409).json({ error: 'الحجز محجوز بالفعل' });
    }
    escrowHolds.set(bookingId, {
      bookingId,
      amount,
      status: 'held',
      heldAt: new Date(),
    });
    res.json({ ok: true, message: `تم حفظ ${amount} SAR للحجز ${bookingId}` });
  } catch {
    res.status(500).json({ error: 'خطأ داخلي' });
  }
});

router.post('/release', requireAuth, (req: any, res) => {
  try {
    const { bookingId } = req.body;
    const hold = escrowHolds.get(bookingId);
    if (!hold) {
      return res.status(404).json({ error: 'لا يوجد حجز محجوز' });
    }
    if (hold.status !== 'held') {
      return res.status(400).json({ error: 'الحجز غير محجوز حالياً' });
    }
    hold.status = 'released';
    hold.releasedAt = new Date();
    res.json({ ok: true, message: `تم تحرير ${hold.amount} SAR من الحجز ${bookingId}` });
  } catch {
    res.status(500).json({ error: 'خطأ داخلي' });
  }
});

router.get('/booking/:id', requireAuth, (req: any, res) => {
  const hold = escrowHolds.get(req.params.id);
  if (!hold) {
    return res.json({ status: 'none' });
  }
  res.json({ status: hold.status, amount: hold.amount });
});

export default router;
