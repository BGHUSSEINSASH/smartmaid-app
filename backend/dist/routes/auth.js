"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const zod_1 = require("zod");
const store_1 = require("../store");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
function issueToken(user) {
    const secret = process.env.JWT_SECRET;
    return secret
        ? jsonwebtoken_1.default.sign({ sub: user.id, role: user.role }, secret, { expiresIn: '7d' })
        : `demo-token-${user.id}`;
}
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
router.post('/login', auth_1.rateLimitLogin, async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
        res
            .status(400)
            .json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const user = store_1.users.find((candidate) => candidate.email.toLowerCase() === parsed.data.email.toLowerCase());
    if (!user || !user.passwordHash) {
        res.status(401).json({ message: 'Invalid credentials' });
        return;
    }
    const ok = await bcryptjs_1.default.compare(parsed.data.password, user.passwordHash);
    if (!ok) {
        res.status(401).json({ message: 'Invalid credentials' });
        return;
    }
    const secret = process.env.JWT_SECRET;
    const token = secret
        ? jsonwebtoken_1.default.sign({ sub: user.id, role: user.role }, secret, {
            expiresIn: '7d',
        })
        : `demo-token-${user.id}`;
    res.json({
        token,
        user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
        },
    });
});
const registerSchema = zod_1.z.object({
    name: zod_1.z.string().min(2),
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(8),
    role: zod_1.z.enum(['customer', 'worker', 'company']).optional(),
});
router.post('/register', async (req, res) => {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
        res
            .status(400)
            .json({ message: 'Invalid payload', errors: parsed.error.flatten() });
        return;
    }
    const exists = store_1.users.find((u) => u.email.toLowerCase() === parsed.data.email.toLowerCase());
    if (exists) {
        res.status(409).json({ message: 'Email already registered' });
        return;
    }
    const user = await (0, store_1.createUser)({
        name: parsed.data.name,
        email: parsed.data.email,
        password: parsed.data.password,
        role: (parsed.data.role ?? 'customer'),
    });
    res.status(201).json({
        token: issueToken(user),
        user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
        },
    });
});
const forgotSchema = zod_1.z.object({ email: zod_1.z.string().email() });
router.post('/forgot-password', (req, res) => {
    const parsed = forgotSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const user = store_1.users.find((u) => u.email.toLowerCase() === parsed.data.email.toLowerCase());
    // لا نكشف إن كان البريد موجوداً (حماية من التعداد).
    if (user) {
        const code = String(Math.floor(1000 + Math.random() * 9000));
        store_1.passwordResetCodes.set(user.email.toLowerCase(), code);
        // في الإنتاج يُرسل عبر البريد. هنا نعيده في وضع التطوير فقط.
        const devCode = process.env.NODE_ENV === 'production' ? undefined : code;
        res.json({ message: 'Reset code sent', devCode });
        return;
    }
    res.json({ message: 'Reset code sent' });
});
const resetSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    code: zod_1.z.string().min(4),
    newPassword: zod_1.z.string().min(8),
});
router.post('/reset-password', async (req, res) => {
    const parsed = resetSchema.safeParse(req.body);
    if (!parsed.success) {
        res.status(400).json({ message: 'Invalid payload' });
        return;
    }
    const key = parsed.data.email.toLowerCase();
    const expected = store_1.passwordResetCodes.get(key);
    if (!expected || expected !== parsed.data.code) {
        res.status(400).json({ message: 'Invalid or expired code' });
        return;
    }
    const user = store_1.users.find((u) => u.email.toLowerCase() === key);
    if (!user) {
        res.status(404).json({ message: 'User not found' });
        return;
    }
    await (0, store_1.updateUserPassword)(user, parsed.data.newPassword);
    store_1.passwordResetCodes.delete(key);
    res.json({ message: 'Password updated' });
});
exports.default = router;
