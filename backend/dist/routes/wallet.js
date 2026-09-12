"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/', auth_1.requireAuth, (req, res) => {
    const userId = req.user.id;
    const txs = store_1.walletTransactions
        .filter((t) => t.userId === userId)
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    const balance = txs.reduce((sum, t) => sum + t.amount, 0);
    res.json({ balance, transactions: txs });
});
router.post('/topup', auth_1.requireAuth, (req, res) => {
    const schema = zod_1.z.object({ amount: zod_1.z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid amount' });
        return;
    }
    store_1.walletTransactions.push({
        id: `t_${Date.now()}`,
        userId: req.user.id,
        title: 'شحن المحفظة',
        amount: parsed.data.amount,
        type: 'topup',
        createdAt: new Date().toISOString(),
    });
    res.status(201).json({ message: 'Wallet topped up' });
});
router.post('/withdraw', auth_1.requireAuth, (0, auth_1.requireRole)('worker', 'admin'), (req, res) => {
    const schema = zod_1.z.object({ amount: zod_1.z.number().positive() });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid amount' });
        return;
    }
    store_1.walletTransactions.push({
        id: `t_${Date.now()}`,
        userId: req.user.id,
        title: 'طلب سحب أرباح',
        amount: -parsed.data.amount,
        type: 'withdrawal',
        createdAt: new Date().toISOString(),
    });
    res.status(201).json({ message: 'Withdrawal requested' });
});
exports.default = router;
