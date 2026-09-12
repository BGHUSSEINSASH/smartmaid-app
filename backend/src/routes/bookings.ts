import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, type AuthedRequest } from '../middleware/auth';
import { bookings, workers } from '../store';

const router = Router();

const bookingSchema = z.object({
  workerId: z.string().min(1),
  contractType: z.enum(['hourly', 'daily', 'monthly']),
  hours: z.number().int().positive(),
  notes: z.string().optional(),
});

router.post('/', requireAuth, (req: AuthedRequest, res) => {
  const parsed = bookingSchema.safeParse(req.body);

  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }

  const worker = workers.find((item) => item.id == parsed.data.workerId);
  if (!worker) {
    res.status(404).json({ message: 'Worker not found' });
    return;
  }

  const booking = {
    id: `b_${Date.now()}`,
    userId: req.user!.id,
    workerId: worker.id,
    contractType: parsed.data.contractType,
    hours: parsed.data.hours,
    notes: parsed.data.notes,
    total: parsed.data.hours * worker.hourlyRate,
    status: 'pending' as const,
    paymentStatus: 'pending' as const,
    createdAt: new Date().toISOString(),
  };

  bookings.unshift(booking);
  res.status(201).json(booking);
});

router.get('/:id', requireAuth, (req: AuthedRequest, res) => {
  const booking = bookings.find((item) => item.id === req.params.id && item.userId === req.user!.id);

  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }

  res.json(booking);
});

export default router;
