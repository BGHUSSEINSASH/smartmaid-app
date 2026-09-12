"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const kycSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2),
    nationalId: zod_1.z.string().min(10),
    selfieUrl: zod_1.z.string().url().optional(),
});
const kycRecords = new Map();
router.post('/verify', auth_1.requireAuth, (req, res) => {
    try {
        const parsed = kycSchema.safeParse(req.body);
        if (!parsed.success) {
            return res.status(400).json({ error: 'بيانات غير صحيحة', details: parsed.error.issues });
        }
        const { fullName, nationalId, selfieUrl } = parsed.data;
        const userId = req.user.id;
        kycRecords.set(userId, {
            userId,
            fullName,
            nationalId: nationalId.slice(0, 4) + '****' + nationalId.slice(-4),
            selfieUrl,
            status: 'pending',
            submittedAt: new Date(),
        });
        res.json({ ok: true, message: 'تم إرسال بيانات التحقق — ستتم المراجعة خلال 24 ساعة' });
    }
    catch (err) {
        res.status(500).json({ error: 'خطأ داخلي' });
    }
});
router.get('/status', auth_1.requireAuth, (req, res) => {
    const record = kycRecords.get(req.user.id);
    if (!record) {
        return res.json({ verified: false, status: 'none' });
    }
    res.json({ verified: record.status === 'approved', status: record.status });
});
exports.default = router;
