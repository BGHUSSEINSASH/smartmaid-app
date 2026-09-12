import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth';

const router = Router();

const kycSchema = z.object({
  fullName: z.string().min(2),
  nationalId: z.string().min(10),
  selfieUrl: z.string().url().optional(),
});

const kycRecords: Map<string, {
  userId: string;
  fullName: string;
  nationalId: string;
  selfieUrl?: string;
  status: 'pending' | 'approved' | 'rejected';
  submittedAt: Date;
}> = new Map();

router.post('/verify', requireAuth, (req: any, res) => {
  try {
    const parsed = kycSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'بيانات غير صحيحة', details: parsed.error.issues });
    }
    const { fullName, nationalId, selfieUrl } = parsed.data;
    const userId = req.user.id;

    kycRecords.set(userId, {
      userId,
      fullName,
      nationalId: nationalId.slice(0, 4) + '****' + nationalId.slice(-4),
      selfieUrl,
      status: 'pending',
      submittedAt: new Date(),
    });

    res.json({ ok: true, message: 'تم إرسال بيانات التحقق — ستتم المراجعة خلال 24 ساعة' });
  } catch (err) {
    res.status(500).json({ error: 'خطأ داخلي' });
  }
});

router.get('/status', requireAuth, (req: any, res) => {
  const record = kycRecords.get(req.user.id);
  if (!record) {
    return res.json({ verified: false, status: 'none' });
  }
  res.json({ verified: record.status === 'approved', status: record.status });
});

export default router;
