import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.role == AppRole.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('سياسة الخصوصية وحماية البيانات',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                ]),
                const SizedBox(height: 6),
                const Text('آخر تحديث: سبتمبر 2026  |  تاريخ النفاذ: أكتوبر 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                const SizedBox(height: 4),
                const Text('باستخدام التطبيق توافق على هذه السياسة.',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('توضح هذه السياسة كيفية جمع المعلومات الشخصية واستخدامها وحمايتها عند استخدام تطبيق شغّالتي (SmartMaid) وخدماته المرتبطة.',
              style: TextStyle(fontSize: 13.5, height: 1.75)),
          const SizedBox(height: 16),
          ..._articles.map((a) => _ArticleTile(number: a[0], title: a[1], body: a[2])),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.warning.withValues(alpha: .3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.admin_panel_settings_rounded, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Text('إدارة السياسة — للمدير فقط',
                        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.warning, fontSize: 14)),
                  ]),
                  const SizedBox(height: 10),
                  const Text('يمكنك تحديث مواد سياسة الخصوصية ودليل الاستخدام من هنا.',
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 14),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _AdminBtn(icon: Icons.edit_rounded, label: 'تحرير مادة', color: AppColors.primary,
                        onTap: () => _editDialog(context, 'تحرير مادة')),
                    _AdminBtn(icon: Icons.add_circle_rounded, label: 'إضافة مادة', color: AppColors.success,
                        onTap: () => _editDialog(context, 'إضافة مادة جديدة')),
                    _AdminBtn(icon: Icons.delete_rounded, label: 'حذف مادة', color: AppColors.error,
                        onTap: () => _editDialog(context, 'حذف مادة')),
                    _AdminBtn(icon: Icons.publish_rounded, label: 'نشر التحديث', color: AppColors.warning,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ تم نشر التحديث'), behavior: SnackBarBehavior.floating))),
                  ]),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .05), borderRadius: BorderRadius.circular(12)),
            child: const Text('للتواصل بشأن الخصوصية: support@shaghalti.app',
                style: TextStyle(fontSize: 12, color: AppColors.muted), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  void _editDialog(BuildContext ctx, String title) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text(title),
      content: const TextField(decoration: InputDecoration(hintText: 'أدخل المحتوى...'), maxLines: 5),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('تم الحفظ'), behavior: SnackBarBehavior.floating)); }, child: const Text('حفظ')),
      ],
    ));
  }
}

// مواد السياسة
const _articles = [
  ['1','التعريف بالمنصة','يُقصد بتطبيق شغّالتي أو «المنصة» التطبيق الإلكتروني والموقع الإلكتروني وأي خدمات أو أدوات أو قنوات تابعة له. ويُقصد بـ«المستخدم» كل شخص يتصفح المنصة أو ينشئ حسابًا أو يطلب خدمة من خلالها.'],
  ['2','المعلومات التي نجمعها','قد تجمع المنصة: الاسم، ورقم الهاتف، والبريد الإلكتروني، والعنوان أو موقع تقديم الخدمة، ومعلومات الحساب، وتفاصيل الحجز، ووسيلة الدفع، والملاحظات المتعلقة بالخدمة، وأي مراسلات أو بلاغات أو تقييمات يرسلها المستخدم.\n\nكذلك معلومات تقنية مثل نوع الجهاز، ونظام التشغيل، وعنوان بروتوكول الإنترنت، وسجلات الدخول.'],
  ['3','كيفية استخدام المعلومات','تُستخدم المعلومات لـ: إنشاء الحساب وإدارته، ومعالجة الحجوزات، والتواصل مع المستخدم، وتنسيق وصول العامل، وإتمام الدفع، ومعالجة الشكاوى، وتحسين المنصة، واكتشاف الاحتيال، والامتثال للالتزامات القانونية.'],
  ['4','الموقع الجغرافي','قد تطلب المنصة الوصول إلى الموقع الجغرافي لتحديد منطقة تقديم الخدمة وتحسين دقة العنوان وتسهيل وصول العامل. يجوز للمستخدم رفض صلاحية الموقع من إعدادات جهازه.'],
  ['5','مشاركة المعلومات مع المورّد والعامل','عند تنفيذ الحجز قد تتم مشاركة المعلومات الضرورية مع المورّد أو العامل: اسم المستخدم، ورقم التواصل، والعنوان، وموعد الحجز، ونوع الخدمة. تقتصر المشاركة على الحد الضروري لتقديم الخدمة.'],
  ['6','التواصل بين العميل والعامل','قد تتيح المنصة وسائل اتصال بين المستخدم والعامل لتنسيق تفاصيل الخدمة. يُحظر استخدام بيانات الاتصال لأغراض شخصية أو تجارية خارج نطاق الخدمة.'],
  ['7','مشاركة المعلومات مع الجهات الأخرى','لا تُباع المعلومات الشخصية. قد تُشارك مع مزودي خدمات الدفع، ومزودي الاستضافة والتقنية، والجهات الحكومية أو القضائية المختصة عند الضرورة.'],
  ['8','الإعلانات والعروض','قد تعرض المنصة إعلانات من شغّالتي أو شركاء خارجيين. يمكن للمستخدم إلغاء الاشتراك في الرسائل التسويقية من إعدادات الحساب.'],
  ['9','ملفات الارتباط والتقنيات المشابهة','قد تستخدم المنصة ملفات الارتباط وأدوات التحليل لحفظ تفضيلات المستخدم وقياس أداء التطبيق وتحسين تجربة الاستخدام.'],
  ['10','حماية المعلومات','تتخذ شغّالتي إجراءات تقنية وتنظيمية معقولة لحماية المعلومات تشمل التشفير أثناء النقل وضوابط الوصول. على المستخدم المحافظة على سرية كلمة المرور ورموز التحقق.'],
  ['11','الاحتفاظ بالمعلومات','تحتفظ المنصة بالمعلومات للمدة اللازمة لتحقيق الأغراض الموضحة أو للوفاء بالالتزامات القانونية أو لحل النزاعات.'],
  ['12','حذف الحساب والبيانات','يمكن للمستخدم طلب إغلاق حسابه أو حذف معلوماته من خلال إعدادات الحساب أو التواصل مع دعم شغّالتي.'],
  ['13','البيانات المجهولة أو المجمعة','يجوز للمنصة استخدام بيانات مجهولة الهوية لأغراض التحليل والإحصاء وتحسين الخدمات دون إعادة تحديد هوية المستخدم.'],
  ['14','مسؤولية المستخدم عن البيانات','يلتزم المستخدم بتقديم معلومات صحيحة ومحدثة وكاملة، وإبلاغ شغّالتي فورًا عند الاشتباه في استخدام غير مصرح به.'],
  ['15','تعليمات الوصول إلى موقع الخدمة','قد يحتاج المستخدم لتزويد المنصة بتعليمات الوصول. يُنصح بعدم إرسال كلمات مرور أو وثائق حساسة إلا عند الضرورة القصوى.'],
  ['16','بيانات الأشخاص الآخرين','إذا قدم المستخدم معلومات عن أفراد أسرته أو أشخاص موجودين في موقع الخدمة، يجب التأكد من وجود أساس مناسب لتقديم تلك المعلومات.'],
  ['17','بيانات العاملين والمورّدين','قد تجمع شغّالتي بيانات تعريفية ومهنية من العاملين والمورّدين للتحقق من الأهلية والامتثال لمتطلبات السلامة والتعاقد.'],
  ['18','حقوق المستخدم','قد يكون للمستخدم الحق في طلب الوصول إلى معلوماته أو تصحيحها أو حذفها أو تقييد استخدامها. يمكن تقديم الطلبات عبر قسم الدعم داخل التطبيق.'],
  ['19','أمن الحساب','يجب اختيار كلمة مرور قوية وعدم مشاركة رموز التحقق وتسجيل الخروج من الأجهزة المشتركة.'],
  ['20','التغييرات على السياسة','قد تُحدَّث هذه السياسة من وقت لآخر. تُنشر النسخة المحدثة داخل التطبيق مع ذكر تاريخ آخر تحديث.'],
  ['21','التواصل','للاستفسارات: support@shaghalti.app أو من خلال قسم الدعم داخل التطبيق.'],
  ['22','القانون المختص','تخضع هذه السياسة للقوانين النافذة في جمهورية العراق. وتُحل النزاعات أمام الجهات المختصة.'],
  ['23','الموافقة','باستخدام المنصة يقر المستخدم بأنه قرأ هذه السياسة وفهمها ويوافق على جمع معلوماته واستخدامها بالحدود الموضحة فيها.'],
];

class _ArticleTile extends StatefulWidget {
  final String number, title, body;
  const _ArticleTile({required this.number, required this.title, required this.body});
  @override
  State<_ArticleTile> createState() => _ArticleTileState();
}

class _ArticleTileState extends State<_ArticleTile> {
  bool _exp = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1E50) : AppColors.stroke,
        ),
        // Glow خفيف في dark mode
        boxShadow: isDark
            ? [BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _exp = !_exp),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  // إصلاح: لون مناسب في dark mode
                  color: isDark
                      ? AppColors.primary.withOpacity(0.22)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(widget.number, style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('المادة ${widget.number}: ${widget.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white : null,
                  ))),
              Icon(_exp ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: isDark ? Colors.white54 : AppColors.muted, size: 18),
            ]),
            if (_exp) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: isDark ? const Color(0xFF1E1E50) : null),
              const SizedBox(height: 8),
              Text(widget.body, style: TextStyle(
                fontSize: 12.5,
                height: 1.75,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              )),
            ],
          ]),
        ),
      ),
    );
  }
}

class _AdminBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color.withValues(alpha:.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha:.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
        ]),
      ),
    );
  }
}
