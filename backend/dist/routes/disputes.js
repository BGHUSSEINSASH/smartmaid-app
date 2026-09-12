"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const disputes = [
    {
        id: 'd_4092',
        bookingId: 'b_demo_1',
        userId: 'u_customer_1',
        category: 'تأخير',
        subject: 'العاملة تأخرت ساعتين',
        detail: 'وصلت العاملة متأخرة عن الموعد المحدد دون إشعار مسبق.',
        status: 'open',
        createdAt: new Date(Date.now() - 86400000).toISOString(),
    },
];
const disputeSchema = zod_1.z.object({
    bookingId: zod_1.z.string().min(1),
    category: zod_1.z.string().min(2),
    subject: zod_1.z.string().min(3),
    detail: zod_1.z.string().min(10),
});
router.get('/', auth_1.requireAuth, (req, res) => {
    res.json({ disputes, total: disputes.length });
});
router.post('/', auth_1.requireAuth, (req, res) => {
    const parsed = disputeSchema.safeParse(req.body);
    if (!parsed.success) {
        return res.status(400).json({ error: 'بيانات غير صحيحة', details: parsed.error.issues });
    }
    const dispute = {
        id: `d_${Date.now()}`,
        bookingId: parsed.data.bookingId,
        userId: req.user.id,
        category: parsed.data.category,
        subject: parsed.data.subject,
        detail: parsed.data.detail,
        status: 'open',
        createdAt: new Date().toISOString(),
    };
    disputes.unshift(dispute);
    res.status(201).json({ ok: true, dispute });
});
router.post('/:id/status', auth_1.requireAuth, (req, res) => {
    const dispute = disputes.find((d) => d.id === req.params.id);
    if (!dispute)
        return res.status(404).json({ error: 'نزاع غير موجود' });
    const status = String(req.body?.status ?? '');
    if (!['open', 'reviewing', 'resolved'].includes(status)) {
        return res.status(400).json({ error: 'حالة غير صحيحة' });
    }
    dispute.status = status;
    res.json({ ok: true, dispute });
});
exports.default = router;
