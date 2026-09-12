"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/', (_req, res) => {
    res.json({ coupons: store_1.coupons });
});
router.post('/apply', (req, res) => {
    const code = String(req.body?.code ?? '').toUpperCase();
    const total = Number(req.body?.total ?? 0);
    const coupon = store_1.coupons.find((c) => c.code === code);
    if (!coupon) {
        res.status(404).json({ message: 'Coupon not found' });
        return;
    }
    if (total < coupon.minTotal) {
        res.status(400).json({ message: `Minimum total is ${coupon.minTotal}` });
        return;
    }
    res.json({
        ...coupon,
        discount: (total * coupon.discountPercent) / 100,
    });
});
exports.default = router;
