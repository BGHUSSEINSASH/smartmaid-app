# خطة التحسين الاحترافي الشامل A→G — Smart Maid

> الحالة: **معتمدة من المستخدم، بانتظار رفع قاعدة `edit: deny`** لبدء التنفيذ.
> بعد السماح بالتعديل: نفّذ المراحل بالترتيب A → B → C → E → D → F → G ثم التحقق النهائي.

## حزم pubspec.yaml الجديدة
```yaml
dependencies:
  go_router: ^14.6.0
  cached_network_image: ^3.4.1
  confetti: ^0.8.0
dev_dependencies:
  flutter_native_splash: ^2.4.3
  flutter_launcher_icons: ^0.14.1
```
Backend: `npm i bcryptjs jsonwebtoken` + أنواعها.

---

## المرحلة A — الجودة الحرجة

### A1 ملف جديد `lib/core/theme/adaptive.dart`
- إضافة `AppColors.strokeDark = Color(0xFF334155)` في app_theme.dart
- Extension على BuildContext: `isDark / surface / pageBg / stroke / ink / mutedText / headerGradient / heroSoftGradient`
- مكوّنان: `SurfaceCard` (بديل موحد للكروت البيضاء) و`AdaptiveHeader` (هيدر متدرج يتكيف)
- تعديل `ProCard` في widgets/pro_components.dart ليستخدم ألوان الثيم بدل `AppColors.surface`

### A2 ملف جديد `lib/widgets/state_views.dart`
`AsyncStateView<T>` يغلف: ShimmerSkeleton عند التحميل، EmptyState الموجود، وحالة خطأ بزر «إعادة المحاولة».

### A3 إزالة التأخيرات المصطنعة + Refresh
- home_screen: حذف `_isLoading` و`Future.delayed(700ms)` → عرض مباشر، وتغليف الـCustomScrollView بـRefreshIndicator
- admin_screen: نفس الشيء (600ms)
- my_bookings/chat_list: RefreshIndicator

### A4 صحة Backend
- provider جديد `backendHealthProvider` (Timer كل 30 ثانية يستدعي `/health`)
- شريط MaterialBanner أعلى MainShell عند الفشل: «تعذر الاتصال بالخادم — يعمل ببيانات تجريبية»

### A5 تمريرة الألوان المقسّوة (sweep)
| الملف | التعديل |
|---|---|
| home_screen | هيدر `Color(0xFFFFF7E6)/(0xFFE8F8F2)` → `context.headerGradient`، scaffold `AppColors.bg` → `context.pageBg`، بطاقة البحث `AppColors.surface` → `context.surface` |
| admin_screen | الهيدر والخلفية كما فوق |
| company_dashboard | الهيدر (`Color(0xFFF8FAFF)/(0xFFEDEBFF)`) والنصوص `textPrimary/ink` → adaptive |
| profile_screen | `backgroundColor: AppColors.backgroundLight` → `context.pageBg` |
| catalog_screen | خلفية وهيدر adaptive |

## المرحلة B — لمسة راقية
1. `lib/widgets/app_image.dart`: غلاف CachedNetworkImage (placeholder = shimmer دائرة/مربع) واستبدال كل NetworkImage (~12 موقعاً: بطاقات الرئيسية، الأفاتارات، هيرو العاملة، الدرج، المحادثات)
2. `lib/core/nav/app_nav.dart`: دوال `pushSlide/pushFade` تستخدم SlideInRoute من animations.dart، واستبدال MaterialPageRoute في نقاط التنقل الرئيسية (تفاصيل عاملة، حجز، محفظة…)
3. payment_screen شاشة النجاح: ConfettiController + AnimatedCounter للمبلغ
4. `lib/core/ui/feedback.dart`: `appSnack(context,msg,{success,error,info})` + `showAppSheet()` بمقبض سحب، توحيد كل ScaffoldMessenger (~18 موقعاً) والـBottom Sheets (~7)
5. HapticsHelper: lightImpact عند الإعجاب/الإرسال، mediumImpact عند تأكيد الدفع/قبول طلب
6. أيقونة + Splash: سكربت PowerShell يولد `assets/icon/icon.png` (1024px تدرج بنفسجي + 🧹 عبر System.Drawing)، إعداد flutter_launcher_icons + flutter_native_splash (خلفية #4F46E5)، ثم `dart run` للأمرين

## المرحلة C — معمارية
### C1 go_router
- `lib/core/router/app_router.dart`: StatefulShellRoute.indexedStack بـ4 فروع (أدوار) كل فرع 5 تبويبات حالية؛ مسارات: /booking /bookings /bookings/:id /worker/:id /chat/:id? /wallet /loyalty /offers /addresses /referral /faq /search /settings /assistant
- redirect guard: غير مسجل → /login (ما عدا onboarding/splash)؛ مسارات الشركة محظورة على غيرها
- استبدال كل Navigator.push (~25) بـ`context.push(...)` تدريجياً؛ MainShell يصبح Shell widget

### C2 Repositories
`lib/data/repositories/`: base_repo.dart (نمط tryApiElseDemo) + auth/bookings/wallet/loyalty/offers/reviews/notifications/addresses repos؛ الـproviders تستهلكها بدل DemoData مباشرة

### C3 LocalStore
توسيع session_store إلى `LocalStore` مع مفاتيح JSON: bookings/wallet/favs/points/addresses/couponsApplied — hydrate عند الإقلاع (في SplashScreen bootstrap) + write-through في كل notifier

## المرحلة E — اختبارات وCI
- test/providers_test.dart: تسعير العقود الأربعة، خصم كوبون + رفض حد أدنى، ولاء earn/redeem/غير كافٍ، wallet topup/pay/withdraw حراسه، favorites toggle
- widget_test: setMockInitialValues → دخول سريع لكل دور والتحقق من 5 تبويبات
- .github/workflows/ci.yml: job1 ubuntu flutter analyze+test، job2 backend npm ci && npx tsc --noEmit

## المرحلة D — l10n
l10n.yaml (gen:true) + app_ar.arb/app_en.arb ~160 نصاً (شل مشترك، تنقل، رحلة الحجز، الدفع، المحفظة، الولاء، العروض، الإعدادات، الأخطاء، FAQ، الكتالوج). app.dart يستهلك settingsProvider.language. الاستبدال يبدأ بالمكونات المشتركة والشِل ثم الشاشات الرئيسية؛ نصوص FAQ/الكتالوج تُترجم كاملة (محدودة العدد).

## المرحلة F — أمان Backend
- store.ts: مستخدمو البذرة بكلمات مقزمة (bcryptjs hashSync وقت الإقلاع) + JWT_SECRET env
- auth.ts: bcrypt.compare + jwt.sign({sub,role}, expiresIn 7d)؛ middleware/auth يتحقق verify
- payments/status: requireAuth + مالك الحجز أو admin
- bookings: فحص الملكية في GET/:id والإلغاء
- middleware/rateLimit.ts: نافذة 15د/20 محاولة على POST /auth/login

## المرحلة G — مميزات واو
1. AssistantScreen: شات يستدعي ollama-proxy `/api/chat` مع system prompt يحوي قائمة العاملات JSON (--dart-define=OLLAMA_PROXY_KEY)؛ fallback مطابقة كلمات مفتاحية→فئة تعمل دائماً؛ اقتراحات عاملات قابلة للنقر داخل فقاعة الرد؛ tile «المساعد الذكي ✨» أعلى ChatListScreen
2. address_screen: حقل بحث Nominatim (`https://nominatim.openstreetmap.org/search?format=json&limit=5`, User-Agent header) بقائمة اقتراحات، حفظ lat/lon وعرضهما + زر نسخ
3. RemindersService: عند إنشاء حجز يسجل موعد تذكير (قبل ساعة)؛ فحص عند كل إقلاع وزيارة لوحة → إشعار داخلي + بانر (بديل Windows-safe للإشعارات المحلية)
4. AchievementsProvider: شارات من بيانات فعلية (أول حجز 🥇، 3 حجوزات 🔥، مقيم ⭐، موفر 💰 استخدم كوبون، اجتماعي 👥 referral، وفّي 🏆 tier≥silver) — قسم في loyalty_screen + صف شارات في profile_screen

## التحقق النهائي
flutter analyze (صفر) • flutter test (كلها خضراء) • npx tsc --noEmit • build windows من C:\smart_maid_seed + تشغيل وفحص السجل

## مخاطر وملاحظات
- go_router refactor واسع → يُنفذ دفعة واحدة مع grep لكل Navigator.push
- l10n فرق كبير لكنه ميكانيكي
- أيقونة مولدة برمجياً = placeholder قابل للاستبدال بأصل هوية حقيقي لاحقاً
