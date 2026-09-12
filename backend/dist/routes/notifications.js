"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/', auth_1.requireAuth, (req, res) => {
    const list = store_1.notifications
        .filter((n) => !n.userId || n.userId === req.user.id)
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    res.json({ notifications: list, unread: list.filter((n) => !n.read).length });
});
router.post('/:id/read', auth_1.requireAuth, (req, res) => {
    const n = store_1.notifications.find((x) => x.id === req.params.id && (!x.userId || x.userId === req.user.id));
    if (!n) {
        res.status(404).json({ message: 'Not found' });
        return;
    }
    n.read = true;
    res.json(n);
});
router.post('/read-all', auth_1.requireAuth, (req, res) => {
    for (const n of store_1.notifications) {
        if (!n.userId || n.userId === req.user.id)
            n.read = true;
    }
    res.json({ message: 'All marked read' });
});
exports.default = router;
