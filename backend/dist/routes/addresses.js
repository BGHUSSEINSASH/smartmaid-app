"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_1 = require("../middleware/auth");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/', auth_1.requireAuth, (req, res) => {
    res.json({
        addresses: store_1.addresses.filter((a) => a.userId === req.user.id),
    });
});
const upsertSchema = zod_1.z.object({
    id: zod_1.z.string().optional(),
    label: zod_1.z.string().min(1),
    city: zod_1.z.string().min(1),
    details: zod_1.z.string().min(1),
    isDefault: zod_1.z.boolean().optional(),
});
router.post('/', auth_1.requireAuth, (req, res) => {
    const parsed = upsertSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const data = parsed.data;
    if (data.isDefault) {
        for (const a of store_1.addresses.filter((a) => a.userId === req.user.id)) {
            a.isDefault = false;
        }
    }
    if (data.id) {
        const existing = store_1.addresses.find((a) => a.id === data.id && a.userId === req.user.id);
        if (!existing) {
            res.status(404).json({ message: 'Not found' });
            return;
        }
        Object.assign(existing, data);
        res.json(existing);
        return;
    }
    const address = {
        id: `a_${Date.now()}`,
        userId: req.user.id,
        label: data.label,
        city: data.city,
        details: data.details,
        isDefault: data.isDefault ?? false,
    };
    store_1.addresses.push(address);
    res.status(201).json(address);
});
router.delete('/:id', auth_1.requireAuth, (req, res) => {
    const idx = store_1.addresses.findIndex((a) => a.id === req.params.id && a.userId === req.user.id);
    if (idx < 0) {
        res.status(404).json({ message: 'Not found' });
        return;
    }
    store_1.addresses.splice(idx, 1);
    res.json({ message: 'Deleted' });
});
exports.default = router;
