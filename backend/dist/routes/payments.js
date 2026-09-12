"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhookHandler = stripeWebhookHandler;
const express_1 = require("express");
const stripe_1 = __importDefault(require("stripe"));
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
const stripe = stripeSecret
    ? new stripe_1.default(stripeSecret, {
        apiVersion: '2024-06-20',
    })
    : null;
const intentSchema = zod_1.z.object({
    bookingId: zod_1.z.string().min(1),
});
const updateStatusSchema = zod_1.z.object({
    paymentStatus: zod_1.z.enum(['succeeded', 'failed', 'processing']),
});
router.post('/intent', auth_1.requireAuth, (req, res) => {
    const parsed = intentSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const booking = store_1.bookings.find((item) => item.id === parsed.data.bookingId && item.userId === req.user.id);
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
router.post('/:paymentId/status', auth_1.requireAuth, (0, auth_1.requireRole)('admin', 'worker'), (req, res) => {
    const parsed = updateStatusSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const booking = store_1.bookings.find((item) => item.paymentIntentId === req.params.paymentId);
    if (!booking) {
        res.status(404).json({ message: 'Payment not found' });
        return;
    }
    if (req.user.role !== 'admin' && booking.userId !== req.user.id) {
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
function stripeWebhookHandler(req, res) {
    try {
        let event;
        if (stripe && stripeWebhookSecret) {
            const signature = req.header('stripe-signature');
            if (!signature) {
                res.status(400).json({ message: 'Missing Stripe signature' });
                return;
            }
            event = stripe.webhooks.constructEvent(req.body, signature, stripeWebhookSecret);
        }
        else {
            // Allows local testing without Stripe credentials.
            event = typeof req.body === 'string' ? JSON.parse(req.body) : JSON.parse(req.body.toString('utf8'));
        }
        if (event.type === 'payment_intent.succeeded') {
            const paymentIntentId = event.data.object.id;
            const booking = store_1.bookings.find((item) => item.paymentIntentId === paymentIntentId);
            if (booking) {
                booking.paymentStatus = 'succeeded';
                booking.status = 'accepted';
            }
        }
        res.json({ received: true });
    }
    catch (error) {
        res.status(400).json({
            message: 'Webhook validation failed',
            error: error instanceof Error ? error.message : 'Unknown error',
        });
    }
}
exports.default = router;
