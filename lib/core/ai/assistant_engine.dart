// ignore_for_file: prefer_const_declarations
import '../../data/demo_data.dart';
import '../../data/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  نتيجة تطابق عاملة مع الاستعلام
// ─────────────────────────────────────────────────────────────────────────────
class AssistantMatch {
  final String workerId;
  final String name;
  final String reason;
  final double matchScore;
  final String? imageUrl;

  const AssistantMatch({
    required this.workerId,
    required this.name,
    required this.reason,
    this.matchScore = 1.0,
    this.imageUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  قاموس الكلمات المفتاحية الموسّع — 20 تصنيف، 200+ كلمة
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, List<String>> _kKeywords = {

  // ── تنظيف عام ──────────────────────────────────────────────────────
  'تنظيف': [
    'تنظيف', 'نظيف', 'نظافة', 'كنس', 'مسح', 'مكنسة', 'شقة', 'بيت', 'بيتي',
    'منزل', 'منزلي', 'ترتيب', 'تنظيم', 'تلميع', 'clean', 'cleaning', 'house',
    'home', 'شغالة', 'خادمة', 'خادم', 'عاملة', 'شغل', 'مساعدة', 'غرفة',
    'صالة', 'ممر', 'غبار', 'درج', 'دور',
  ],

  // ── تنظيف عميق ─────────────────────────────────────────────────────
  'تنظيف عميق': [
    'عميق', 'شامل', 'كامل', 'بخار', 'تعقيم', 'تطهير', 'دهون', 'حمام',
    'مطبخ', 'بلاط', 'سيراميك', 'ارضية', 'أرضية', 'deep', 'steam',
    'disinfect', 'sanitize', 'عفن', 'روائح', 'رائحة', 'سخام',
    'شاملة', 'كاملة', 'من أعلى', 'من الأسفل',
  ],

  // ── طبخ ────────────────────────────────────────────────────────────
  'طبخ': [
    'طبخ', 'طباخة', 'طاهية', 'أكل', 'أكله', 'غداء', 'عشاء', 'فطور',
    'وجبة', 'وجبات', 'مطبخ', 'طعام', 'cook', 'cooking', 'chef', 'food',
    'ريوق', 'حلو', 'حلويات', 'كيك', 'خبز', 'معجنات', 'بيتية',
    'طبق', 'أطباق', 'طهو', 'وصفة', 'مطبوخ', 'نظام غذائي', 'حمية',
    'رجيم', 'سلطة', 'شوربة', 'مرق', 'باستا', 'أرز', 'لحم',
  ],

  // ── رعاية أطفال ────────────────────────────────────────────────────
  'رعاية الأطفال': [
    'أطفال', 'طفل', 'جليسة', 'بيبي', 'رضيع', 'حضانة', 'مربية',
    'baby', 'babysitter', 'nanny', 'kids', 'children', 'infant',
    'صغار', 'صغير', 'ولد', 'بنت', 'رعاية', 'اطفال', 'تربية',
    'متابعة الأطفال', 'تعليم', 'لعب', 'مدرسة', 'واجبات', 'درس',
    'عناية', 'يرعى', 'يعتني', 'حمل الأطفال',
  ],

  // ── رعاية كبار السن ────────────────────────────────────────────────
  'رعاية كبار السن': [
    'مسن', 'مسنين', 'عجوز', 'جدة', 'جد', 'كبير', 'كبار السن',
    'تمريض', 'ممرضة', 'elderly', 'senior', 'nursing', 'رعاية كبار',
    'والدة', 'والد', 'أهل كبار', 'مريض', 'مريضة', 'احتياجات خاصة',
    'عناية', 'متابعة', 'شيخوخة', 'دار مسنين', 'جليسة مسن',
  ],

  // ── غسيل وكواء ─────────────────────────────────────────────────────
  'غسيل وكواء': [
    'غسيل', 'كواء', 'كي', 'ملابس', 'ثياب', 'مكوى', 'حديد',
    'laundry', 'ironing', 'iron', 'washing', 'clothes', 'تنشيف',
    'جفف', 'تجفيف', 'بشكير', 'ستارة', 'ستائر', 'سجادة', 'فرشة',
    'مفرش', 'شراشف', 'كيس وسادة', 'غيار', 'نشر',
  ],

  // ── بستنة وحديقة ───────────────────────────────────────────────────
  'بستنة': [
    'حديقة', 'نباتات', 'نبات', 'عشب', 'زرع', 'شجرة', 'ورد', 'زهور',
    'garden', 'plant', 'gardening', 'lawn', 'حشيش', 'ري', 'تقليم',
    'تسميد', 'تنسيق حديقة', 'شرفة', 'بالكون', 'أصص',
  ],

  // ── ترتيب وتنظيم ───────────────────────────────────────────────────
  'ترتيب': [
    'ترتيب', 'تنظيم', 'دولاب', 'خزانة', 'رف', 'تخزين', 'organize',
    'storage', 'closet', 'فوضى', 'عشوائية', 'تنسيق', 'مرتب',
    'مقتنيات', 'فرز', 'إعادة ترتيب', 'تصنيف',
  ],

  // ── خدمات شاملة / دوام ─────────────────────────────────────────────
  'خدمات شاملة': [
    'شغل', 'عمل', 'مساعدة', 'خدمة', 'يومي', 'شهري', 'دوام',
    'سنوي', 'كل يوم', 'دوري', 'أسبوعي', 'متفرغة', 'مقيمة',
    'داخلية', 'نصف دوام', 'كل أسبوع', 'ساعات', 'بالساعة', 'يوم',
    'full time', 'part time', 'فورية', 'الآن', 'اليوم', 'سريعة',
  ],

  // ── تنظيف مكاتب / تجاري ───────────────────────────────────────────
  'تنظيف مكاتب': [
    'مكتب', 'مكاتب', 'شركة', 'عمل', 'تجاري', 'office', 'commercial',
    'محل', 'محلات', 'عيادة', 'كافيه', 'مطعم', 'فندق', 'صالة انتظار',
    'أرضية مكتب', 'زجاج', 'نوافذ',
  ],

  // ── تنظيف سجاد ─────────────────────────────────────────────────────
  'تنظيف سجاد': [
    'سجادة', 'سجاد', 'موكيت', 'بساط', 'carpet', 'rug', 'تنظيف سجاد',
    'شامبو سجاد', 'بقعة', 'بقع', 'تلطيخ',
  ],

  // ── تنظيف نوافذ ─────────────────────────────────────────────────────
  'تنظيف زجاج': [
    'زجاج', 'نافذة', 'نوافذ', 'شباك', 'مرآة', 'glass', 'window',
    'مرايا', 'واجهة', 'شفاف', 'تلميع زجاج',
  ],

  // ── تعليم ودعم ──────────────────────────────────────────────────────
  'تعليم': [
    'تعليم', 'دروس', 'مدرسة', 'واجبات', 'مذاكرة', 'مدرسة',
    'دراسة', 'مساعدة أطفال', 'teaching', 'tutor', 'homework',
    'تأهيل', 'تدريب', 'قراءة', 'كتابة',
  ],

  // ── صفات العاملة ───────────────────────────────────────────────────
  'جودة عالية': [
    'خبيرة', 'خبرة', 'محترفة', 'ماهرة', 'متمرسة', 'متخصصة',
    'professional', 'experienced', 'expert', 'skilled', 'موثوقة',
    'أمينة', 'نظيفة', 'منضبطة', 'دقيقة', 'سريعة', 'ممتازة',
    'راقية', 'مميزة', 'أفضل', 'تقييم عالي',
  ],

  // ── توافر وموقع ─────────────────────────────────────────────────────
  'متاحة': [
    'متاحة', 'متوفرة', 'فاضية', 'فارغة', 'available', 'free',
    'الآن', 'فوراً', 'فوري', 'عاجل', 'طارئ', 'اليوم', 'غداً',
    'الأسبوع', 'قريبة', 'قريب', 'منطقتي', 'منطقة',
  ],

  // ── رخيصة / اقتصادية ────────────────────────────────────────────────
  'اقتصادية': [
    'رخيص', 'رخيصة', 'اقتصادي', 'سعر', 'أسعار', 'تكلفة', 'ميزانية',
    'cheap', 'affordable', 'budget', 'مناسب', 'معقول', 'بسعر',
    'أقل سعر', 'أرخص', 'تخفيض', 'خصم',
  ],

  // ── طوارئ / عاجل ────────────────────────────────────────────────────
  'طارئ': [
    'طارئ', 'طوارئ', 'عاجل', 'ضروري', 'مستعجل', 'الآن', 'فوراً',
    'urgent', 'emergency', 'asap', 'بسرعة', 'يوم نفسه',
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
//  Levenshtein distance
// ─────────────────────────────────────────────────────────────────────────────
int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final la = a.length, lb = b.length;
  final dp = List.generate(la + 1, (i) => List.filled(lb + 1, 0));
  for (var i = 0; i <= la; i++) dp[i][0] = i;
  for (var j = 0; j <= lb; j++) dp[0][j] = j;
  for (var i = 1; i <= la; i++) {
    for (var j = 1; j <= lb; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1]
          : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce((x, y) => x < y ? x : y);
    }
  }
  return dp[la][lb];
}

// ─────────────────────────────────────────────────────────────────────────────
//  مطابقة تقريبية — تتسامح مع خطأ إملائي وتدعم البحث الجزئي
// ─────────────────────────────────────────────────────────────────────────────
bool _fuzzyContains(String text, String keyword) {
  final t = text.trim().toLowerCase();
  final k = keyword.toLowerCase();
  if (t.contains(k)) return true;
  if (k.length < 4) return false; // كلمات قصيرة جداً: دقة كاملة فقط

  // مطابقة كلمة-بكلمة مع تسامح بـ Levenshtein
  final words = t.split(RegExp(r'[\s،,]+'));
  final maxDist = k.length <= 5 ? 1 : 2;
  for (final word in words) {
    if (word.length >= 3 && _levenshtein(word, k) <= maxDist) return true;
    // مطابقة جزئية: keyword يبدأ بـ word أو العكس
    if (word.length >= 3 && k.length >= 3 &&
        (k.startsWith(word) || word.startsWith(k))) return true;
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  الدالة الرئيسية — تُعيد عاملات مرتّبة بحسب درجة التطابق
// ─────────────────────────────────────────────────────────────────────────────
List<AssistantMatch> matchWorkers(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return [];

  final pool = <WorkerModel>[...DemoData.workers, ...DemoData.companyWorkers];

  // الخطوة 1 — تحديد التصنيفات المطلوبة من الاستعلام
  final wantedCategories = <String>{};
  for (final entry in _kKeywords.entries) {
    for (final kw in entry.value) {
      if (_fuzzyContains(q, kw)) {
        wantedCategories.add(entry.key);
        break;
      }
    }
  }

  // الخطوة 2 — تحديد نوايا إضافية من الاستعلام
  final wantsAvailable = _fuzzyContains(q, 'متاحة') ||
      _fuzzyContains(q, 'الآن') || _fuzzyContains(q, 'فوراً') ||
      _fuzzyContains(q, 'اليوم') || _fuzzyContains(q, 'available');

  final wantsCheap = _fuzzyContains(q, 'رخيص') ||
      _fuzzyContains(q, 'اقتصادي') || _fuzzyContains(q, 'سعر');

  final wantsTopRated = _fuzzyContains(q, 'أفضل') ||
      _fuzzyContains(q, 'خبيرة') || _fuzzyContains(q, 'ممتازة') ||
      _fuzzyContains(q, 'محترفة') || _fuzzyContains(q, 'تقييم عالي');

  // الخطوة 3 — حساب درجة كل عاملة
  final scored = <(WorkerModel, double, String)>[];

  for (final w in pool) {
    double score = 0.0;
    final reasons = <String>[];

    final wCat = w.category.toLowerCase();
    final wName = w.name.toLowerCase();
    final wAbout = w.about.toLowerCase();
    final wLoc = w.location.toLowerCase();
    final wSkills = w.skills.map((s) => s.toLowerCase()).toList();

    // ── مطابقة التصنيف الرئيسي (+0.45) ────────────────────────────
    if (wantedCategories.isNotEmpty) {
      bool catHit = false;
      for (final cat in wantedCategories) {
        // التصنيف الخاص بالعاملة يحتوي الكلمة الأساسية؟
        final catKeyword = cat.split(' ').first; // 'تنظيف' من 'تنظيف عميق'
        if (_fuzzyContains(wCat, catKeyword) || _fuzzyContains(wCat, cat)) {
          score += 0.45;
          reasons.add(cat);
          catHit = true;
          break;
        }
      }
      // مهاراتها تطابق التصنيف؟ (+0.20)
      if (!catHit) {
        for (final cat in wantedCategories) {
          final catKeyword = cat.split(' ').first;
          if (wSkills.any((s) => _fuzzyContains(s, catKeyword) || _fuzzyContains(s, cat))) {
            score += 0.20;
            reasons.add('مهارة: $cat');
            break;
          }
        }
      }
    } else {
      // لا تصنيف واضح — بحث في الاسم والوصف والمهارات
      if (_fuzzyContains(wName, q)) { score += 0.40; reasons.add('اسم'); }
      if (_fuzzyContains(wAbout, q)) { score += 0.25; reasons.add('وصف'); }
      if (wSkills.any((s) => _fuzzyContains(s, q))) { score += 0.20; reasons.add('مهارة'); }
      if (_fuzzyContains(wCat, q)) { score += 0.30; reasons.add('تصنيف'); }
      if (_fuzzyContains(wLoc, q)) { score += 0.15; reasons.add('موقع'); }
    }

    // ── مكافآت إضافية ──────────────────────────────────────────────

    // مطابقة اسم العاملة مع الاستعلام (+0.10)
    if (_fuzzyContains(wName, q) && score > 0) score += 0.10;

    // مطابقة الوصف (+0.08)
    if (wAbout.isNotEmpty && _fuzzyContains(wAbout, q) && score > 0) score += 0.08;

    // متاحة (+0.12 عند الطلب، +0.05 عموماً)
    if (w.isAvailable) {
      score += wantsAvailable ? 0.12 : 0.05;
      if (wantsAvailable) reasons.add('متاحة الآن');
    } else if (wantsAvailable) {
      score *= 0.6; // خفّض النتيجة إذا طلب المتاحة وهي غير متاحة
    }

    // تقييم عالٍ (+0.15 max)
    final ratingBonus = (w.rating / 5.0) * 0.15;
    score += ratingBonus;
    if (w.rating >= 4.8) reasons.add('تقييم ممتاز ${w.rating}⭐');

    // أعلى تقييم عند الطلب (+0.10)
    if (wantsTopRated && w.rating >= 4.5) score += 0.10;

    // موثّقة (+0.03)
    if (w.verified) score += 0.03;

    // عدد المهام يعكس الخبرة (+0.05 max)
    score += (w.jobsCompleted / 300).clamp(0.0, 0.05);

    // سعر منخفض (+0.08 عند الطلب)
    if (wantsCheap && w.hourlyRate > 0) {
      final allRates = pool.where((p) => p.hourlyRate > 0).map((p) => p.hourlyRate).toList()..sort();
      final median = allRates[allRates.length ~/ 2];
      if (w.hourlyRate < median) { score += 0.08; reasons.add('سعر مناسب'); }
    }

    // حد أدنى لإظهار النتيجة
    final minScore = wantedCategories.isNotEmpty ? 0.15 : 0.10;
    if (score >= minScore) {
      scored.add((w, score.clamp(0.0, 1.0), reasons.join(' + ')));
    }
  }

  // الخطوة 4 — ترتيب: score تنازلياً، ثم rating تنازلياً
  scored.sort((a, b) {
    final cmp = b.$2.compareTo(a.$2);
    return cmp != 0 ? cmp : b.$1.rating.compareTo(a.$1.rating);
  });

  // الخطوة 5 — Fallback: إذا لم تجد شيئاً → بحث نصي مباشر
  if (scored.isEmpty) {
    for (final w in pool) {
      final wCat = w.category.toLowerCase();
      final wName = w.name.toLowerCase();
      final wSkills = w.skills.map((s) => s.toLowerCase()).toList();
      if (_fuzzyContains(wName, q) || _fuzzyContains(wCat, q) ||
          wSkills.any((s) => _fuzzyContains(s, q))) {
        scored.add((w, 0.45, 'بحث مباشر'));
      }
    }
  }

  return scored.map((t) => AssistantMatch(
    workerId: t.$1.id,
    name: t.$1.name,
    reason: t.$3.isEmpty ? t.$1.category : t.$3,
    matchScore: t.$2,
    imageUrl: t.$1.imageUrl,
  )).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
//  اقتراح تصحيح — يجد أقرب keyword لعبارة البحث
// ─────────────────────────────────────────────────────────────────────────────
String? suggestCorrection(String query) {
  if (query.trim().length < 2) return null;
  final q = query.trim().toLowerCase();
  String? best;
  int bestDist = 4; // حد أقصى

  for (final keywords in _kKeywords.values) {
    for (final kw in keywords) {
      if (kw.length < 3) continue;
      final d = _levenshtein(q, kw.toLowerCase());
      if (d < bestDist) {
        bestDist = d;
        best = kw;
      }
      // مطابقة جزئية: الـ keyword يحتوي الاستعلام
      if (kw.contains(q) && q.length >= 3) {
        best = kw;
        bestDist = 0;
        break;
      }
    }
    if (bestDist == 0) break;
  }
  return best;
}

// ─────────────────────────────────────────────────────────────────────────────
//  رد احتياطي للمساعد الذكي
// ─────────────────────────────────────────────────────────────────────────────
String buildFallbackReply(String query) {
  final q = query.trim().toLowerCase();

  if (_fuzzyContains(q, 'طبخ') || _fuzzyContains(q, 'أكل') || _fuzzyContains(q, 'وجبة')) {
    return 'يسعدني مساعدتك! لدينا طباخات خبيرات في المطبخ العربي والعالمي. هل تريد طباخة يومية أم لمناسبة خاصة؟';
  }
  if (_fuzzyContains(q, 'أطفال') || _fuzzyContains(q, 'جليسة') || _fuzzyContains(q, 'بيبي')) {
    return 'ممتاز! لدينا جليسات أطفال موثّقات ومدرّبات. كم عمر طفلك وكم ساعة تحتاج الرعاية؟';
  }
  if (_fuzzyContains(q, 'مسن') || _fuzzyContains(q, 'كبار السن') || _fuzzyContains(q, 'عجوز')) {
    return 'بالتأكيد! رعاية كبار السن تحتاج صبراً وخبرة. لدينا ممرضات وجليسات متخصصات. ما هي احتياجات المريض؟';
  }
  if (_fuzzyContains(q, 'تنظيف') || _fuzzyContains(q, 'نظافة') || _fuzzyContains(q, 'شقة')) {
    return 'سأساعدك في إيجاد أفضل عاملة تنظيف! هل تحتاج تنظيف يومي، أسبوعي، أم تنظيف عميق شامل؟';
  }
  if (_fuzzyContains(q, 'غسيل') || _fuzzyContains(q, 'كواء') || _fuzzyContains(q, 'ملابس')) {
    return 'لدينا عاملات متخصصات في الغسيل والكواء. هل تريد خدمة منزلية أم إرسال الملابس؟';
  }
  if (_fuzzyContains(q, 'سعر') || _fuzzyContains(q, 'تكلفة') || _fuzzyContains(q, 'رخيص')) {
    return 'أسعارنا تبدأ من \$20/ساعة. يمكنني مقارنة أسعار العاملات المتاحات. ما نوع الخدمة التي تحتاجها؟';
  }
  if (_fuzzyContains(q, 'متاحة') || _fuzzyContains(q, 'الآن') || _fuzzyContains(q, 'اليوم')) {
    return 'سأعرض لك العاملات المتاحات الآن! ما نوع الخدمة؟';
  }

  return 'يسعدني مساعدتك في إيجاد عاملة مناسبة. يمكنك البحث عن تنظيف، طبخ، رعاية أطفال، رعاية كبار السن، أو أي خدمة منزلية أخرى.';
}
