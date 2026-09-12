"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
const bookingSchema = zod_1.z.object({
    workerId: zod_1.z.string().min(1),
    contractType: zod_1.z.enum(['hourly', 'daily', 'monthly']),
    hours: zod_1.z.number().int().positive(),
    notes: zod_1.z.string().optional(),
});
router.post('/', auth_1.requireAuth, (req, res) => {
    const parsed = bookingSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const worker = store_1.workers.find((item) => item.id == parsed.data.workerId);
    if (!worker) {
        res.status(404).json({ message: 'Worker not found' });
        return;
    }
    const booking = {
        id: `b_${Date.now()}`,
        userId: req.user.id,
        workerId: worker.id,
        contractType: parsed.data.contractType,
        hours: parsed.data.hours,
        notes: parsed.data.notes,
        total: parsed.data.hours * worker.hourlyRate,
        status: 'pending',
        paymentStatus: 'pending',
        createdAt: new Date().toISOString(),
    };
    store_1.bookings.unshift(booking);
    res.status(201).json(booking);
});
router.get('/:id', auth_1.requireAuth, (req, res) => {
    const booking = store_1.bookings.find((item) => item.id === req.params.id && item.userId === req.user.id);
    if (!booking) {
        res.status(404).json({ message: 'Booking not found' });
        return;
    }
    res.json(booking);
});
exports.default = router;
