# Smart Maid System

واجهة Flutter + Backend TypeScript لاختبار سيناريو الحجز والدفع المحلي مع Stripe webhook.

## ما الذي يعتبر التطبيق متكاملاً هنا؟

- تسجيل دخول + أدوار (عميل / عاملة / إدارة / شركة).
- واجهات رئيسية متعددة حسب الدور.
- تدفق حجز كامل مع حالة ومزامنة.
- تدفق دفع كامل مع Payment Intent + Webhook تجريبي.
- شاشة دردشة وتجميع Dashboards للإدارة والعاملة والشركة.
- وضع Demo Seed لتعبئة بيانات جاهزة تلقائياً قبل التشغيل.

## الميزات الجديدة (مرحلة التوسع)

### 🛡️ الثقة والسلامة
- **زر طوارئ SOS** (`/sos` + زر داخل تفاصيل الحجز الجاري) — مرتبط بالـ backend عبر `POST /api/v1/sos` مع fallback تجريبي.
- **توثيق الهوية KYC** (`/kyc`) — نموذج عاملة مرتبط بـ `POST /api/v1/kyc/verify` و`GET /api/v1/kyc/status` مع تخزين الحالة محلياً.
- **فتح نزاع** من تفاصيل الحجز المكتمل — شيت مرتبط بـ `POST /api/v1/disputes` (راوت جديد) وإدارته من شاشة نزاعات الإدارة.

### 🤖 المساعد الذكي (AI)
- راوت جديد `POST /api/v1/ai/chat` — يربط Ollama عبر `ollama-proxy` مع fallback ذكي داخلي عند تعطل النموذج.
- شاشة المساعد تجرب بالترتيب: backend AI → Ollama المباشر → محرك الكلمات المفتاحية المحلي.
- `GET /api/v1/ai/estimate` لتقدير التكلفة السريع.

### 💰 أرباح العاملات
- شاشة **أرباحي ومستحقاتي** (`/settlements`) — مرتبطة بـ `GET /api/v1/settlements/history` مع fallback لبيانات تجريبية.
- راوت `settlements/history` أصبح يُرجع `{ records, total }` (متوافق مع ApiClient).

### 🏗️ طبقة Repository
- `lib/data/repository.dart` — نقطة اتصال موحدة بالـ backend (SOS/KYC/Settlements/AI/Disputes) مع:
  - تحميل تلقائي للتوكن من `SessionStore` قبل كل طلب.
  - تراجع سلس لوضع التجربة عند تعذر الوصول للخادم.

## المتطلبات

- Flutter 3.38+
- Dart 3.10+
- Node.js 20+
- Stripe CLI (اختياري لاختبار webhook الحقيقي)

## تشغيل تطبيق Flutter

```bash
flutter pub get
flutter run -d windows
```

## تشغيل التطبيق مع بيانات تجريبية جاهزة (Seed)

```bash
flutter run -d windows --dart-define=ENABLE_DEMO_SEED=true
```

هذا الخيار يقوم تلقائياً بـ:

- تسجيل دخول مستخدم تجريبي.
- تعبئة بيانات عاملات تجريبية في الواجهة.
- حقن حالة حجز/دفع تجريبية لبدء الاختبار مباشرة.

## ملاحظة مهمة لمسارات ويندوز العربية

إذا فشل بناء ويندوز بسبب المسار العربي، استخدم مسار ASCII (Junction) ثم شغّل منه:

```powershell
cmd /c mklink /J C:\smart_maid_seed "C:\Users\BGHUSSEINSASH\شغالتي"
Set-Location C:\smart_maid_seed
flutter clean
flutter pub get
flutter run -d windows --dart-define=ENABLE_DEMO_SEED=true
```

## تشغيل Backend

```bash
cd backend
npm install
npm run dev
```

الخادم يعمل على:

```txt
http://localhost:4000
```

## حسابات تجريبية

- مستخدم: user@example.com / Passw0rd!
- عاملة: worker@example.com / Passw0rd!
- إدارة: admin@example.com / Passw0rd!

## اختبار Stripe Webhook محليًا

1. انسخ ملف البيئة:

```bash
cd backend
copy .env.example .env
```

2. ضع المفاتيح داخل .env:

```env
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

3. اربط Stripe CLI مع webhook المحلي:

```bash
stripe listen --forward-to localhost:4000/api/v1/payments/webhook/stripe
```

4. أرسل event تجريبي:

```bash
stripe trigger payment_intent.succeeded
```

## هيكل المشروع

```txt
lib/
	core/
	data/
	features/
	widgets/
backend/
	src/routes/
```
