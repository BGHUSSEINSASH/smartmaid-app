import { Router } from 'express';
import { requireAuth } from '../middleware/auth';

const router = Router();

const sosAlerts: Array<{
  id: string;
  userId: string;
  location: string;
  message: string;
  status: 'active' | 'resolved';
  createdAt: Date;
  resolvedAt?: Date;
}> = [];

router.post('/', requireAuth, (req: any, res) => {
  try {
    const { location, message } = req.body;
    const alert = {
      id: `sos_${Date.now()}`,
      userId: req.user.id,
      location: location || 'غير محدد',
      message: message || 'طلب طوارئ',
      status: 'active' as const,
      createdAt: new Date(),
    };
    sosAlerts.push(alert);
    console.log(`[SOS] Alert from user ${req.user.id}: ${alert.message}`);
    res.json({
      ok: true,
      alertId: alert.id,
      message: 'تم إرسال تنبيه الطوارئ — تواصل مع الخط الساخن: 911',
    });
  } catch {
    res.status(500).json({ error: 'خطأ داخلي' });
  }
});

router.get('/status/:id', requireAuth, (req: any, res) => {
  const alert = sosAlerts.find((a) => a.id === req.params.id);
  if (!alert) {
    return res.status(404).json({ error: 'تنبيه غير موجود' });
  }
  res.json(alert);
});

export default router;
