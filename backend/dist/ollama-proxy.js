"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const stream_1 = require("stream");
const app = (0, express_1.default)();
const PORT = Number(process.env.OLLAMA_PROXY_PORT ?? 11435);
const TARGET = process.env.OLLAMA_TARGET ?? 'http://127.0.0.1:11434';
const API_KEY = process.env.OLLAMA_PROXY_API_KEY;
if (!API_KEY) {
    console.error('Missing OLLAMA_PROXY_API_KEY. Refusing to start insecure proxy.');
    process.exit(1);
}
app.use(express_1.default.raw({ type: '*/*', limit: '100mb' }));
app.all('*', async (req, res) => {
    const auth = req.header('authorization') ?? '';
    const expected = `Bearer ${API_KEY}`;
    if (auth !== expected) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
    }
    const upstreamUrl = `${TARGET}${req.originalUrl}`;
    const headers = {};
    for (const [key, value] of Object.entries(req.headers)) {
        if (!value)
            continue;
        if (key.toLowerCase() === 'host')
            continue;
        if (Array.isArray(value)) {
            headers[key] = value.join(', ');
        }
        else {
            headers[key] = value;
        }
    }
    headers.authorization = `Bearer ${API_KEY}`;
    try {
        const upstream = await fetch(upstreamUrl, {
            method: req.method,
            headers,
            body: req.method === 'GET' || req.method === 'HEAD' ? undefined : req.body,
            duplex: 'half',
        });
        res.status(upstream.status);
        upstream.headers.forEach((value, key) => {
            if (key.toLowerCase() === 'transfer-encoding')
                return;
            res.setHeader(key, value);
        });
        if (!upstream.body) {
            res.end();
            return;
        }
        stream_1.Readable.fromWeb(upstream.body).pipe(res);
    }
    catch (error) {
        const message = error instanceof Error ? error.message : 'Proxy error';
        res.status(502).json({ error: message });
    }
});
app.listen(PORT, () => {
    console.log(`Ollama API-key proxy listening on http://127.0.0.1:${PORT}`);
    console.log(`Forward target: ${TARGET}`);
});
