"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logAudit = logAudit;
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const auditLog = [];
function logAudit(action, description, userId) {
    auditLog.unshift({
        id: `al_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
        action,
        description,
        userId,
        timestamp: new Date(),
    });
    if (auditLog.length > 500)
        auditLog.length = 500;
}
router.get('/', auth_1.requireAuth, (req, res) => {
    const { page = '1', limit = '50' } = req.query;
    const start = (Number(page) - 1) * Number(limit);
    const sliced = auditLog.slice(start, start + Number(limit));
    res.json({ entries: sliced, total: auditLog.length });
});
router.get('/action/:action', auth_1.requireAuth, (req, res) => {
    const filtered = auditLog.filter((e) => e.action === req.params.action);
    res.json({ entries: filtered, total: filtered.length });
});
exports.default = router;
