"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const auth_1 = __importDefault(require("./routes/auth"));
const bookings_1 = __importDefault(require("./routes/bookings"));
const payments_1 = __importStar(require("./routes/payments"));
const workers_1 = __importDefault(require("./routes/workers"));
const wallet_1 = __importDefault(require("./routes/wallet"));
const loyalty_1 = __importDefault(require("./routes/loyalty"));
const offers_1 = __importDefault(require("./routes/offers"));
const reviews_1 = __importDefault(require("./routes/reviews"));
const notifications_1 = __importDefault(require("./routes/notifications"));
const addresses_1 = __importDefault(require("./routes/addresses"));
const referrals_1 = __importDefault(require("./routes/referrals"));
const kyc_1 = __importDefault(require("./routes/kyc"));
const escrow_1 = __importDefault(require("./routes/escrow"));
const settlements_1 = __importDefault(require("./routes/settlements"));
const articles_1 = __importDefault(require("./routes/articles"));
const sos_1 = __importDefault(require("./routes/sos"));
const audit_1 = __importDefault(require("./routes/audit"));
const ai_1 = __importDefault(require("./routes/ai"));
const disputes_1 = __importDefault(require("./routes/disputes"));
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, cors_1.default)({
    origin: true,
    credentials: true,
}));
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', service: 'smart-maid-backend' });
});
app.post('/api/v1/payments/webhook/stripe', express_1.default.raw({ type: 'application/json' }), payments_1.stripeWebhookHandler);
app.use(express_1.default.json());
app.use('/api/v1/auth', auth_1.default);
app.use('/api/v1/workers', workers_1.default);
app.use('/api/v1/bookings', bookings_1.default);
app.use('/api/v1/payments', payments_1.default);
app.use('/api/v1/wallet', wallet_1.default);
app.use('/api/v1/loyalty', loyalty_1.default);
app.use('/api/v1/offers', offers_1.default);
app.use('/api/v1/reviews', reviews_1.default);
app.use('/api/v1/notifications', notifications_1.default);
app.use('/api/v1/addresses', addresses_1.default);
app.use('/api/v1/referrals', referrals_1.default);
app.use('/api/v1/kyc', kyc_1.default);
app.use('/api/v1/escrow', escrow_1.default);
app.use('/api/v1/settlements', settlements_1.default);
app.use('/api/v1/articles', articles_1.default);
app.use('/api/v1/sos', sos_1.default);
app.use('/api/v1/audit', audit_1.default);
app.use('/api/v1/ai', ai_1.default);
app.use('/api/v1/disputes', disputes_1.default);
const port = Number(process.env.PORT ?? 4000);
app.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`API listening on http://localhost:${port}`);
});
