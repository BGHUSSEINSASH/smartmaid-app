"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/worker/:workerId', (req, res) => {
    const list = store_1.reviews
        .filter((r) => r.workerId === req.params.workerId)
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    const average = list.length > 0 ? list.reduce((s, r) => s + r.rating, 0) / list.length : 0;
    res.json({ reviews: list, average, count: list.length });
});
router.post('/', auth_1.requireAuth, (req, res) => {
    const schema = zod_1.z.object({
        workerId: zod_1.z.string().min(1),
        rating: zod_1.z.number().min(1).max(5),
        comment: zod_1.z.string().min(1),
    });
    const parsed = schema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const review = {
        id: `r_${Date.now()}`,
        workerId: parsed.data.workerId,
        userId: req.user.id,
        rating: parsed.data.rating,
        comment: parsed.data.comment,
        createdAt: new Date().toISOString(),
    };
    store_1.reviews.push(review);
    res.status(201).json(review);
});
exports.default = router;
