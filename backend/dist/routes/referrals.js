"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/me', auth_1.requireAuth, (req, res) => {
    const code = `SMART-${(req.user.name.split(' ')[0] ?? '').toUpperCase()}-${req.user.id.slice(-4).toUpperCase()}`;
    res.json({ code });
});
router.post('/apply', auth_1.requireAuth, (req, res) => {
    const code = String(req.body?.code ?? '');
    if (!code.startsWith('SMART-')) {
        res.status(400).json({ message: 'Invalid referral code' });
        return;
    }
    const record = store_1.loyaltyByUser.get(req.user.id) ?? { points: 0, history: [] };
    record.points += 100;
    record.history.unshift({
        title: '+100 نقطة من إحالة صديق',
        points: 100,
        at: new Date().toISOString(),
    });
    store_1.loyaltyByUser.set(req.user.id, record);
    res.json({ message: 'Referral applied', points: record.points });
});
exports.default = router;
