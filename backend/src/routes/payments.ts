import { Request, Response, Router } from 'express';
import Stripe from 'stripe';
import { z } from 'zod';
import { requireAuth, requireRole, type AuthedRequest } from '../middleware/auth';
import { bookings } from '../store';

const router = Router();

const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

const stripe = stripeSecret
  ? new Stripe(stripeSecret, {
      apiVersion: '2024-06-20' as never,
    })
  : null;

const intentSchema = z.object({
  bookingId: z.string().min(1),
});

const updateStatusSchema = z.object({
  paymentStatus: z.enum(['succeeded', 'failed', 'processing']),
});

router.post('/intent', requireAuth, (req: AuthedRequest, res) => {
  const parsed = intentSchema.safeParse(req.body);

  if (!parsed.success) {
    res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
    return;
  }

  const booking = bookings.find(
    (item) => item.id === parsed.data.bookingId && item.userId === req.user!.id,
  );

  if (!booking) {
    res.status(404).json({ message: 'Booking not found' });
    return;
  }

  booking.paymentStatus = 'processing';
  booking.paymentIntentId = `pi_mock_${Date.now()}`;

  res.json({
    paymentIntentId: booking.paymentIntentId,
    clientSecret: `${booking.paymentIntentId}_secret_mock`,
    amount: booking.total,
    currency: 'usd',
    bookingId: booking.id,
    paymentStatus: booking.paymentStatus,
  });
});

router.post(
  '/:paymentId/status',
  requireAuth,
  requireRole('admin', 'worker'),
  (req: AuthedRequest, res) => {
    const parsed = updateStatusSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
      return;
    }

    const booking = bookings.find((item) => item.paymentIntentId === req.params.paymentId);

    if (!booking) {
      res.status(404).json({ message: 'Payment not found' });
      return;
    }

    if (req.user!.role !== 'admin' && booking.userId !== req.user!.id) {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }

  booking.paymentStatus = parsed.data.paymentStatus;
  if (parsed.data.paymentStatus === 'succeeded') {
    booking.status = 'accepted';
  }

  res.json({
    bookingId: booking.id,
    paymentIntentId: booking.paymentIntentId,
    paymentStatus: booking.paymentStatus,
    bookingStatus: booking.status,
  });
});

export function stripeWebhookHandler(req: Request, res: Response): void {
  try {
    let event: Stripe.Event;

    if (stripe && stripeWebhookSecret) {
      const signature = req.header('stripe-signature');
      if (!signature) {
        res.status(400).json({ message: 'Missing Stripe signature' });
        return;
      }

      event = stripe.webhooks.constructEvent(req.body, signature, stripeWebhookSecret);
    } else {
      // Allows local testing without Stripe credentials.
      event = typeof req.body === 'string' ? JSON.parse(req.body) : JSON.parse(req.body.toString('utf8'));
    }

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntentId = event.data.object.id;
      const booking = bookings.find((item) => item.paymentIntentId === paymentIntentId);
      if (booking) {
        booking.paymentStatus = 'succeeded';
        booking.status = 'accepted';
      }
    }

    res.json({ received: true });
  } catch (error) {
    res.status(400).json({
      message: 'Webhook validation failed',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
}

export default router;
