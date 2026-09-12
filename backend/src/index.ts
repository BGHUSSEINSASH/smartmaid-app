import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import authRoutes from './routes/auth';
import bookingRoutes from './routes/bookings';
import paymentRoutes, { stripeWebhookHandler } from './routes/payments';
import workerRoutes from './routes/workers';
import walletRoutes from './routes/wallet';
import loyaltyRoutes from './routes/loyalty';
import offersRoutes from './routes/offers';
import reviewsRoutes from './routes/reviews';
import notificationsRoutes from './routes/notifications';
import addressesRoutes from './routes/addresses';
import referralsRoutes from './routes/referrals';
import kycRoutes from './routes/kyc';
import escrowRoutes from './routes/escrow';
import settlementsRoutes from './routes/settlements';
import articlesRoutes from './routes/articles';
import sosRoutes from './routes/sos';
import auditRoutes from './routes/audit';
import aiRoutes from './routes/ai';
import disputesRoutes from './routes/disputes';

dotenv.config();

const app = express();

app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'smart-maid-backend' });
});

app.post(
  '/api/v1/payments/webhook/stripe',
  express.raw({ type: 'application/json' }),
  stripeWebhookHandler,
);

app.use(express.json());

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/workers', workerRoutes);
app.use('/api/v1/bookings', bookingRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/wallet', walletRoutes);
app.use('/api/v1/loyalty', loyaltyRoutes);
app.use('/api/v1/offers', offersRoutes);
app.use('/api/v1/reviews', reviewsRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/addresses', addressesRoutes);
app.use('/api/v1/referrals', referralsRoutes);
app.use('/api/v1/kyc', kycRoutes);
app.use('/api/v1/escrow', escrowRoutes);
app.use('/api/v1/settlements', settlementsRoutes);
app.use('/api/v1/articles', articlesRoutes);
app.use('/api/v1/sos', sosRoutes);
app.use('/api/v1/audit', auditRoutes);
app.use('/api/v1/ai', aiRoutes);
app.use('/api/v1/disputes', disputesRoutes);

const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on http://localhost:${port}`);
});
