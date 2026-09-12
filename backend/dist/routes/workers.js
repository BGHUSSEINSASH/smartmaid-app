"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const store_1 = require("../store");
const router = (0, express_1.Router)();
router.get('/search', (_req, res) => {
    res.json(store_1.workers);
});
exports.default = router;
