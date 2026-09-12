"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.passwordResetCodes = exports.notifications = exports.addresses = exports.reviews = exports.coupons = exports.loyaltyByUser = exports.walletTransactions = exports.bookings = exports.workers = exports.users = void 0;
exports.makeToken = makeToken;
exports.createUser = createUser;
exports.updateUserPassword = updateUserPassword;
exports.parseUserFromToken = parseUserFromToken;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
async function hashSeedPasswords() {
    for (const u of exports.users) {
        if (!u.passwordHash) {
            u.passwordHash = await bcryptjs_1.default.hash(u.password, 10);
        }
    }
}
exports.users = [
    {
        id: 'u_customer_1',
        name: 'Demo User',
        email: 'user@example.com',
        password: 'Passw0rd!',
        role: 'customer',
    },
    {
        id: 'u_worker_1',
        name: 'Demo Worker',
        email: 'worker@example.com',
        password: 'Passw0rd!',
        role: 'worker',
    },
    {
        id: 'u_admin_1',
        name: 'Demo Admin',
        email: 'admin@example.com',
        password: 'Passw0rd!',
        role: 'admin',
    },
    {
        id: 'u_company_1',
        name: 'Ideal Cleaning Co.',
        email: 'company@example.com',
        password: 'Passw0rd!',
        role: 'company',
    },
];
exports.workers = [
    {
        id: 'w1',
        name: 'Maria',
        image: 'https://i.pravatar.cc/160?img=47',
        rating: 4.9,
        experienceYears: 7,
        hourlyRate: 32,
    },
    {
        id: 'w2',
        name: 'Anna',
        image: 'https://i.pravatar.cc/160?img=32',
        rating: 4.8,
        experienceYears: 6,
        hourlyRate: 29,
    },
    {
        id: 'w3',
        name: 'Nour',
        image: 'https://i.pravatar.cc/160?img=15',
        rating: 4.7,
        experienceYears: 5,
        hourlyRate: 27,
    },
];
exports.bookings = [];
exports.walletTransactions = [];
exports.loyaltyByUser = new Map([
    ['u_customer_1', { points: 1250, history: [] }],
]);
exports.coupons = [
    { code: 'SMART50', title: 'خصم النصف', discountPercent: 50, minTotal: 50 },
    { code: 'SAVE15', title: 'وفّر 15%', discountPercent: 15, minTotal: 30 },
    { code: 'MONTHLY10', title: 'باقة الشهر', discountPercent: 10, minTotal: 200 },
];
exports.reviews = [
    {
        id: 'r1',
        workerId: 'w1',
        userId: 'u_customer_1',
        rating: 5,
        comment: 'ممتازة جداً! المنزل نظيف بشكل رائع.',
        createdAt: new Date().toISOString(),
    },
];
exports.addresses = [];
exports.notifications = [];
function makeToken(user) {
    return `demo-token-${user.id}`;
}
/// رموز إعادة تعيين كلمة المرور المؤقتة (بريد -> رمز).
exports.passwordResetCodes = new Map();
/// ينشئ مستخدماً جديداً ويخزّن كلمة المرور مجزّأة.
async function createUser(input) {
    const user = {
        id: `u_${input.role}_${Date.now()}`,
        name: input.name,
        email: input.email,
        password: input.password,
        passwordHash: await bcryptjs_1.default.hash(input.password, 10),
        role: input.role,
    };
    exports.users.push(user);
    return user;
}
/// يحدّث كلمة مرور مستخدم موجود.
async function updateUserPassword(user, newPassword) {
    user.password = newPassword;
    user.passwordHash = await bcryptjs_1.default.hash(newPassword, 10);
}
function parseUserFromToken(token) {
    if (!token || !token.startsWith('demo-token-')) {
        return undefined;
    }
    const userId = token.replace('demo-token-', '');
    return exports.users.find((user) => user.id === userId);
}
void hashSeedPasswords();
