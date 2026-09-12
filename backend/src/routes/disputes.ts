import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, AuthedRequest } from '../middleware/auth';

const router = Router();

export interface Dispute {
  id: string;
  bookingId: string;
  userId: string;
  category: string;
  subject: string;
  detail: string;
  status: 'open' | 'reviewing' | 'resolved';
  createdAt: string;
}

const disputes: Dispute[] = [
  {
    id: 'd_4092',
    bookingId: 'b_demo_1',
    userId: 'u_customer_1',
    category: 'تأخير',
    subject: 'العاملة تأخرت ساعتين',
    detail: 'وصلت العاملة متأخرة عن الموعد المحدد دون إشعار مسبق.',
    status: 'open',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
];

const disputeSchema = z.object({
  bookingId: z.string().min(1),
  category: z.string().min(2),
  subject: z.string().min(3),
  detail: z.string().min(10),
});

router.get('/', requireAuth, (req: any, res) => {
  res.json({ disputes, total: disputes.length });
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const parsed = disputeSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'بيانات غير صحيحة', details: parsed.error.issues });
  }
  const dispute: Dispute = {
    id: `d_${Date.now()}`,
    bookingId: parsed.data.bookingId,
    userId: req.user!.id,
    category: parsed.data.category,
    subject: parsed.data.subject,
    detail: parsed.data.detail,
    status: 'open',
    createdAt: new Date().toISOString(),
  };
  disputes.unshift(dispute);
  res.status(201).json({ ok: true, dispute });
});

router.post('/:id/status', requireAuth, (req: any, res) => {
  const dispute = disputes.find((d) => d.id === req.params.id);
  if (!dispute) return res.status(404).json({ error: 'نزاع غير موجود' });
  const status = String(req.body?.status ?? '');
  if (!['open', 'reviewing', 'resolved'].includes(status)) {
    return res.status(400).json({ error: 'حالة غير صحيحة' });
  }
  dispute.status = status as Dispute['status'];
  res.json({ ok: true, dispute });
});

export default router;
