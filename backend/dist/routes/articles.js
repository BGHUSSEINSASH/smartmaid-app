"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const router = (0, express_1.Router)();
const articles = [
    {
        id: 'a1',
        title: 'كيف تحافظ على نظافة بيتك بين الخدم',
        summary: 'نصائح عملية سريعة تحافظ على نظافة بيتك يومياً',
        category: 'نصائح',
        content: 'نصائح عملية سريعة تحافظ على نظافة بيتك يومياً...',
        author: 'فريق سمارت ميد',
        publishedAt: '2026-08-15',
        readTime: 5,
    },
    {
        id: 'a2',
        title: 'اختيار الخادمة المناسبة لعائلتك',
        summary: 'دليلك الكامل لاختيار أفضل خادمة مناسبة لاحتياجاتك',
        category: 'أدلة',
        content: 'دليلك الكامل لاختيار أفضل خادمة...',
        author: 'فريق سمارت ميد',
        publishedAt: '2026-08-10',
        readTime: 8,
    },
    {
        id: 'a3',
        title: '-types of deep cleaning',
        summary: 'ما الفرق بين التنظيف اليومي والتنظيف العميق',
        category: 'معلومات',
        content: 'التنظيف العميق يشمل areas لا يغطيها التنظيف اليومي...',
        author: 'فريق سمارت ميد',
        publishedAt: '2026-08-05',
        readTime: 4,
    },
    {
        id: 'a4',
        title: 'تعلم فن تنظيف المطبخ احترافياً',
        summary: 'خطوات وitects لتنظيف المطبخ بشكل احترافي',
        category: 'نصائح',
        content: 'خطوات وitects لتنظيف المطبخ بشكل احترافي...',
        author: 'فريق سمارت ميد',
        publishedAt: '2026-08-01',
        readTime: 6,
    },
    {
        id: 'a5',
        title: 'كيف تتعامل مع مواد التنظيف القوية بأمان',
        summary: 'دليل السلامة لاستخدام مواد التنظيف الكيميائية',
        category: 'سلامة',
        content: 'ال precautions عند التعامل مع مواد التنظيف...',
        author: 'فريق سمارت ميد',
        publishedAt: '2026-07-28',
        readTime: 7,
    },
];
router.get('/', (req, res) => {
    const { category } = req.query;
    let result = articles;
    if (category && typeof category === 'string') {
        result = articles.filter((a) => a.category === category);
    }
    res.json({ articles: result, total: result.length });
});
router.get('/:id', (req, res) => {
    const article = articles.find((a) => a.id === req.params.id);
    if (!article) {
        return res.status(404).json({ error: 'المقال غير موجود' });
    }
    res.json(article);
});
exports.default = router;
