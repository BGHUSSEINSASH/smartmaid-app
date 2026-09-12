"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/', auth_1.requireAuth, (req, res) => {
    const record = store_1.loyaltyByUser.get(req.user.id) ?? { points: 0, history: [] };
    const tier = record.points >= 1500 ? 'gold' : record.points >= 500 ? 'silver' : 'bronze';
    res.json({ ...record, tier, pointsPerUsdRedeem: 20 });
});
router.post('/earn', auth_1.requireAuth, (req, res) => {
    const schema = zod_1.z.object({ points: zod_1.z.number().int().positive(), title: zod_1.z.string().min(1) });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const record = store_1.loyaltyByUser.get(req.user.id) ?? { points: 0, history: [] };
    record.points += parsed.data.points;
    record.history.unshift({
        title: parsed.data.title,
        points: parsed.data.points,
        at: new Date().toISOString(),
    });
    store_1.loyaltyByUser.set(req.user.id, record);
    res.json(record);
});
router.post('/redeem', auth_1.requireAuth, (req, res) => {
    const schema = zod_1.z.object({ discountUsd: zod_1.z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const cost = Math.round(parsed.data.discountUsd * 20);
    const record = store_1.loyaltyByUser.get(req.user.id);
    if (!record || cost > record.points) {
        res.status(400).json({ message: 'Not enough points' });
        return;
    }
    record.points -= cost;
    record.history.unshift({
        title: `استبدال بخصم $${parsed.data.discountUsd}`,
        points: -cost,
        at: new Date().toISOString(),
    });
    res.json(record);
});
exports.default = router;
