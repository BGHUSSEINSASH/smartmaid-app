"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const sosAlerts = [];
router.post('/', auth_1.requireAuth, (req, res) => {
    try {
        const { location, message } = req.body;
        const alert = {
            id: `sos_${Date.now()}`,
            userId: req.user.id,
            location: location || 'غير محدد',
            message: message || 'طلب طوارئ',
            status: 'active',
            createdAt: new Date(),
        };
        sosAlerts.push(alert);
        console.log(`[SOS] Alert from user ${req.user.id}: ${alert.message}`);
        res.json({
            ok: true,
            alertId: alert.id,
            message: 'تم إرسال تنبيه الطوارئ — تواصل مع الخط الساخن: 911',
        });
    }
    catch {
        res.status(500).json({ error: 'خطأ داخلي' });
    }
});
router.get('/status/:id', auth_1.requireAuth, (req, res) => {
    const alert = sosAlerts.find((a) => a.id === req.params.id);
    if (!alert) {
        return res.status(404).json({ error: 'تنبيه غير موجود' });
    }
    res.json(alert);
});
exports.default = router;
