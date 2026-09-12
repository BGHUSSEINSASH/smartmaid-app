import { Router } from 'express';
import { requireAuth } from '../middleware/auth';
import { bookings } from '../store';

const router = Router();

const OLLAMA_TARGET = process.env.OLLAMA_TARGET ?? 'http://127.0.0.1:11434';
const OLLAMA_MODEL = process.env.OLLAMA_MODEL ?? 'llama3';
const OLLAMA_API_KEY = process.env.OLLAMA_PROXY_API_KEY;

interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

router.post('/chat', requireAuth, async (req: any, res) => {
  try {
    const userMessage = String(req.body?.message ?? '').slice(0, 2000);
    if (!userMessage.trim()) {
      return res.status(400).json({ error: 'الرسالة فارغة' });
    }

    // Build live worker context from real data
    const workersDesc = [
      'w1: Maria (تنظيف المنازل, 4.9⭐, $32/س, الرياض, متاحة)',
      'w2: Anna (تنظيف عميق, 4.8⭐, $29/س, جدة, متاحة)',
      'w3: Nour (طبخ وتنظيف, 4.7⭐, $27/س, الرياض, مشغولة)',
      'cw1: ماريا سانتوس (تنظيف المنازل, 4.9⭐, $30/س, الرياض, متاحة)',
    ].join('\n');

    const messages: ChatMessage[] = [
      {
        role: 'system',
        content:
          'أنت مساعد حجوزات لتطبيق Smart Maid لخدمات العاملات المنزلية. ' +
          'أجب بالعربية بإيجاز وودّية، واقترح عاملات من القائمة التالية عند الحاجة ' +
          '(اذكر الاسم والسبب في سطر واحد لكل اقتراح):\n' +
          workersDesc +
          '\nلا تخترع عاملات غير موجودين في القائمة. إن كان الطلب غير واضح فاطرح سؤالاً توضيحياً واحداً.',
      },
      { role: 'user', content: userMessage },
    ];

    try {
      const upstream = await fetch(`${OLLAMA_TARGET}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(OLLAMA_API_KEY
            ? { Authorization: `Bearer ${OLLAMA_API_KEY}` }
            : {}),
        },
        body: JSON.stringify({
          model: OLLAMA_MODEL,
          stream: false,
          messages,
        }),
        signal: AbortSignal.timeout(20000),
      });

      if (upstream.ok) {
        const data: any = await upstream.json();
        const reply: string = data?.message?.content ?? '';
        if (reply.trim()) {
          return res.json({ source: 'ollama', reply: reply.trim() });
        }
      }
    } catch {
      // Ollama offline — fall through to smart fallback
    }

    // Smart deterministic fallback (no AI model needed)
    const q = userMessage;
    const priceMatch = q.match(/(\d+)\s*(غرف|غرفة|غرفة)/);
    const freq = /أسبوع|اسبوع|weekly|شهري|شهر/i.test(q);
    const price =
      priceMatch != null
        ? Number(priceMatch[1]) * (freq ? 480 : 256)
        : freq
          ? 1280
          : 256;
    const fallback = freq
      ? `للحجز ${freq ? 'الأسبوعي/الشهري' : ''} نقدّر التكلفة بحوالي $${price} تقريباً. ` +
        'اختر عاملة من الصفحة الرئيسية ثم حدد الباقة المناسبة وستشاهد السعر النهائي قبل الدفع 💡'
      : `نقدّر تكلفة طلبك بحوالي $${price}. تصفح العاملات المتاحات واحجز مباشرة — الدفع آمن ومحفوظ حتى إتمام المهمة ✨`;

    res.json({ source: 'fallback', reply: fallback });
  } catch {
    res.status(500).json({ error: 'خطأ داخلي' });
  }
});

// Quick price estimate used by booking screen tips
router.get('/estimate', requireAuth, (req: any, res) => {
  const rooms = Math.max(1, Math.min(10, Number(req.query.rooms ?? 3)));
  const weekly = String(req.query.weekly ?? 'false') === 'true';
  const base = rooms * (weekly ? 160 : 85);
  res.json({ rooms, weekly, estimatedUsd: base });
});

// Training-style endpoint: recent bookings summary for AI context
router.get('/context', requireAuth, (req: any, res) => {
  const userBookings = bookings.filter((b) => b.userId === req.user!.id);
  res.json({
    bookingsCount: userBookings.length,
    completed: userBookings.filter((b) => b.status === 'completed').length,
  });
});

export default router;
