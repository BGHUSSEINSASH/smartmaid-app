"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
exports.requireRole = requireRole;
exports.rateLimitLogin = rateLimitLogin;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const store_1 = require("../store");
function resolveTokenUser(token) {
    if (!token)
        return undefined;
    const secret = process.env.JWT_SECRET;
    if (secret) {
        try {
            const payload = jsonwebtoken_1.default.verify(token, secret);
            return store_1.users.find((u) => u.id === payload.sub);
        }
        catch {
            return undefined;
        }
    }
    return (0, store_1.parseUserFromToken)(token);
}
function requireAuth(req, res, next) {
    const authorization = req.header('authorization') ?? '';
    const token = authorization.startsWith('Bearer ')
        ? authorization.slice(7)
        : undefined;
    const user = resolveTokenUser(token);
    if (!user) {
        res.status(401).json({ message: 'Unauthorized' });
        return;
    }
    req.user = user;
    next();
}
function requireRole(...roles) {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401).json({ message: 'Unauthorized' });
            return;
        }
        if (roles.length > 0 && !roles.includes(req.user.role)) {
            res.status(403).json({ message: 'Forbidden' });
            return;
        }
        next();
    };
}
const loginAttempts = new Map();
const WINDOW_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 20;
function rateLimitLogin(req, res, next) {
    const key = req.ip ?? 'unknown';
    const now = Date.now();
    const attempts = (loginAttempts.get(key) ?? []).filter((t) => now - t < WINDOW_MS);
    if (attempts.length >= MAX_ATTEMPTS) {
        res.status(429).json({ message: 'Too many attempts, try later' });
        return;
    }
    attempts.push(now);
    loginAttempts.set(key, attempts);
    next();
}
