import 'models.dart';

class DemoData {
  DemoData._();

  static WorkerModel? byId(String id) {
    for (final w in [...workers, ...companyWorkers]) {
      if (w.id == id) return w;
    }
    return null;
  }

  static final reviews = <ReviewModel>[
    ReviewModel(
      id: 'r1',
      reviewerName: 'سارة العتيبي',
      reviewerImage: 'https://i.pravatar.cc/150?img=5',
      rating: 5.0,
      comment: 'ممتازة جداً! المنزل نظيف بشكل رائع، منظمة ومحترفة.',
      date: DateTime(2024, 12, 20),
      photos: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=300',
        'https://images.unsplash.com/photo-1527515637462-cff94eebd21f?w=300',
      ],
    ),
    ReviewModel(
      id: 'r2',
      reviewerName: 'نورة الشمري',
      reviewerImage: 'https://i.pravatar.cc/150?img=9',
      rating: 4.5,
      comment: 'عمل ممتاز، التزمت بالوقت والمنزل نظيف جداً. سأطلبها مجدداً.',
      date: DateTime(2024, 12, 15),
    ),
    ReviewModel(
      id: 'r3',
      reviewerName: 'أحمد المالكي',
      reviewerImage: 'https://i.pravatar.cc/150?img=68',
      rating: 5.0,
      comment: 'خدمة رائعة، موثوقة وأمينة. أنصح بها بشدة.',
      date: DateTime(2024, 12, 8),
      photos: [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=300',
      ],
    ),
    ReviewModel(
      id: 'r4',
      reviewerName: 'منى الحربي',
      reviewerImage: 'https://i.pravatar.cc/150?img=44',
      rating: 4.0,
      comment: 'جيدة في التنظيف، تحتاج بعض التحسين في الترتيب.',
      date: DateTime(2024, 11, 28),
    ),
  ];

  static const extraServices = <ExtraService>[
    ExtraService(id: 'deep', name: 'تنظيف عميق', icon: '🧹', priceUsd: 20),
    ExtraService(id: 'laundry', name: 'غسيل ملابس', icon: '👕', priceUsd: 15),
    ExtraService(id: 'iron', name: 'كي الملابس', icon: '👔', priceUsd: 10),
    ExtraService(id: 'cooking', name: 'طبخ', icon: '🍳', priceUsd: 25),
    ExtraService(id: 'baby', name: 'رعاية أطفال', icon: '👶', priceUsd: 20),
    ExtraService(
      id: 'shopping',
      name: 'تسوق ومشتريات',
      icon: '🛒',
      priceUsd: 15,
    ),
    ExtraService(id: 'elderly', name: 'رعاية مسنين', icon: '👴', priceUsd: 20),
    ExtraService(id: 'plants', name: 'رعاية النباتات', icon: '🌱', priceUsd: 8),
    ExtraService(id: 'tools', name: 'أحتاج أدوات التنظيف', icon: '🧹', priceUsd: 10),
  ];

  static const customer = AppUser(
    id: 'u1',
    name: 'أحمد محمد',
    email: 'customer@demo.com',
    imageUrl: 'https://i.pravatar.cc/150?img=68',
    role: AppRole.customer,
    phone: '+966 50 123 4567',
    location: 'الرياض، حي النزهة',
  );

  static const workerUser = AppUser(
    id: 'u2',
    name: 'ماريا سانتوس',
    email: 'worker@demo.com',
    imageUrl: 'https://i.pravatar.cc/150?img=47',
    role: AppRole.worker,
    phone: '+966 55 987 6543',
    location: 'الرياض، حي العليا',
  );

  static const admin = AppUser(
    id: 'u3',
    name: 'مدير النظام',
    email: 'admin@demo.com',
    imageUrl: 'https://i.pravatar.cc/150?img=70',
    role: AppRole.admin,
    phone: '+966 50 555 0000',
    location: 'الرياض',
  );

  static const companyUser = AppUser(
    id: 'u4',
    name: 'شركة النظافة المثالية',
    email: 'company@demo.com',
    imageUrl: 'https://i.pravatar.cc/150?img=60',
    role: AppRole.company,
    phone: '+966 11 222 3333',
    location: 'الرياض',
  );

  static const companies = <CompanyModel>[
    CompanyModel(
      id: 'co1',
      name: 'شركة النظافة المثالية',
      logoUrl: 'https://i.pravatar.cc/150?img=60',
      description:
          'شركة رائدة في خدمات النظافة المنزلية والتجارية بخبرة تزيد على 10 سنوات في السوق السعودي. نوفر عاملات مدربات ومعتمدات بأعلى معايير الجودة.',
      location: 'الرياض',
      isPro: true,
      rating: 4.9,
      workerCount: 35,
      specialties: ['تنظيف المنازل', 'تنظيف عميق', 'تنظيف مكاتب'],
      contactEmail: 'info@mithali.com',
      contactPhone: '+966 11 222 3333',
    ),
    CompanyModel(
      id: 'co2',
      name: 'مجموعة الرعاية الشاملة',
      logoUrl: 'https://i.pravatar.cc/150?img=61',
      description:
          'متخصصون في رعاية الأطفال وكبار السن وتوفير العاملات المنزليات المحترفات. خدماتنا تشمل الرعاية الصحية والاجتماعية.',
      location: 'جدة',
      isPro: true,
      rating: 4.8,
      workerCount: 28,
      specialties: ['رعاية الأطفال', 'رعاية كبار السن', 'طبخ وتنظيف'],
      contactEmail: 'info@care-group.com',
      contactPhone: '+966 12 333 4444',
    ),
    CompanyModel(
      id: 'co3',
      name: 'بيت الخدمات المتكاملة',
      logoUrl: 'https://i.pravatar.cc/150?img=62',
      description:
          'نقدم حلولاً متكاملة للمنازل والفلل والمجمعات السكنية. فريق من العاملات المتخصصات في جميع أنواع الخدمات المنزلية.',
      location: 'الدمام',
      isPro: false,
      rating: 4.7,
      workerCount: 22,
      specialties: ['تنظيف عميق', 'طبخ', 'تنظيف عميق', 'كي الملابس'],
      contactEmail: 'info@bait-services.com',
      contactPhone: '+966 13 444 5555',
    ),
  ];

  static const companyWorkers = <WorkerModel>[
    WorkerModel(
      id: 'cw1',
      name: 'روزا فيرنانديز',
      category: 'تنظيف المنازل',
      imageUrl: 'https://i.pravatar.cc/150?img=53',
      rating: 4.9,
      reviewCount: 189,
      jobsCompleted: 243,
      hourlyRate: 22,
      location: 'الرياض',
      isAvailable: true,
      skills: ['التنظيف الشامل', 'المطبخ', 'الأرضيات', 'الغسيل'],
      about:
          'عاملة منزل محترفة ضمن شركة النظافة المثالية. خبرة 6 سنوات في التنظيف الشامل.',
      companyId: 'co1',
      verified: true,
    ),
    WorkerModel(
      id: 'cw2',
      name: 'دياموند ريوس',
      category: 'تنظيف عميق',
      imageUrl: 'https://i.pravatar.cc/150?img=54',
      rating: 4.8,
      reviewCount: 145,
      jobsCompleted: 198,
      hourlyRate: 28,
      location: 'الرياض',
      isAvailable: true,
      skills: ['التنظيف بالبخار', 'التعقيم', 'إزالة الأوساخ', 'الحمامات'],
      about:
          'متخصصة في التنظيف العميق والتعقيم ضمن فريق شركة النظافة المثالية.',
      companyId: 'co1',
      verified: true,
    ),
    WorkerModel(
      id: 'cw3',
      name: 'جين باركر',
      category: 'رعاية الأطفال',
      imageUrl: 'https://i.pravatar.cc/150?img=55',
      rating: 5.0,
      reviewCount: 212,
      jobsCompleted: 278,
      hourlyRate: 25,
      location: 'جدة',
      isAvailable: false,
      skills: ['رعاية الأطفال', 'الأنشطة التعليمية', 'الإسعافات الأولية'],
      about:
          'مربية أطفال محترفة تعمل ضمن مجموعة الرعاية الشاملة بخبرة 8 سنوات.',
      companyId: 'co2',
      verified: true,
    ),
    WorkerModel(
      id: 'cw4',
      name: 'سونيا ميندوزا',
      category: 'طبخ وتنظيف',
      imageUrl: 'https://i.pravatar.cc/150?img=56',
      rating: 4.7,
      reviewCount: 134,
      jobsCompleted: 167,
      hourlyRate: 30,
      location: 'الدمام',
      isAvailable: true,
      skills: ['الطبخ', 'التنظيف', 'الكي', 'الغسيل'],
      about:
          'تعمل ضمن بيت الخدمات المتكاملة في الدمام، متخصصة في الطبخ والتنظيف.',
      companyId: 'co3',
    ),
  ];

  static final workers = <WorkerModel>[
    const WorkerModel(
      id: 'w1',
      name: 'ماريا سانتوس',
      category: 'تنظيف المنازل',
      imageUrl: 'https://i.pravatar.cc/150?img=47',
      rating: 4.9,
      reviewCount: 247,
      jobsCompleted: 312,
      hourlyRate: 25,
      location: 'الرياض',
      isAvailable: true,
      skills: ['التنظيف العميق', 'المطبخ', 'الحمامات', 'غرف النوم'],
      about:
          'خبرة 7 سنوات في تنظيف المنازل بمعايير عالية. موثوقة ومحترفة ومعتمدة.',
      verified: true,
    ),
    const WorkerModel(
      id: 'w2',
      name: 'فاطمة الحسن',
      category: 'طبخ وتنظيف',
      imageUrl: 'https://i.pravatar.cc/150?img=48',
      rating: 4.8,
      reviewCount: 183,
      jobsCompleted: 228,
      hourlyRate: 30,
      location: 'جدة',
      isAvailable: true,
      skills: ['الطبخ العربي', 'الطبخ الآسيوي', 'التنظيف', 'الترتيب'],
      about: 'شيف منزلية ماهرة متخصصة في المطبخ العربي والشرقي بخبرة 5 سنوات.',
    ),
    const WorkerModel(
      id: 'w3',
      name: 'آنا كوفالسكي',
      category: 'رعاية الأطفال',
      imageUrl: 'https://i.pravatar.cc/150?img=49',
      rating: 4.9,
      reviewCount: 312,
      jobsCompleted: 389,
      hourlyRate: 22,
      location: 'الرياض',
      isAvailable: false,
      skills: [
        'رعاية الأطفال',
        'الأنشطة التعليمية',
        'السباحة',
        'الإسعافات الأولية',
      ],
      about:
          'مربية أطفال محترفة بخبرة 9 سنوات. حاصلة على شهادة رعاية أطفال معتمدة.',
    ),
    const WorkerModel(
      id: 'w4',
      name: 'نور خليل',
      category: 'رعاية كبار السن',
      imageUrl: 'https://i.pravatar.cc/150?img=50',
      rating: 4.7,
      reviewCount: 156,
      jobsCompleted: 198,
      hourlyRate: 28,
      location: 'الدمام',
      isAvailable: true,
      skills: ['رعاية المسنين', 'العلاج الطبيعي', 'إعداد الأدوية', 'المرافقة'],
      about: 'متخصصة في رعاية كبار السن بحنان واحتراف وتدريب طبي معتمد.',
    ),
    const WorkerModel(
      id: 'w5',
      name: 'لينا رودريغيز',
      category: 'تنظيف عميق',
      imageUrl: 'https://i.pravatar.cc/150?img=51',
      rating: 4.8,
      reviewCount: 201,
      jobsCompleted: 267,
      hourlyRate: 35,
      location: 'الرياض',
      isAvailable: true,
      skills: ['التنظيف بالبخار', 'إزالة البقع', 'التعقيم', 'الأثاث والسجاد'],
      about: 'متخصصة في التنظيف العميق والشامل للمنازل الكبيرة.',
    ),
    const WorkerModel(
      id: 'w6',
      name: 'ياسمين أحمد',
      category: 'تنظيف مكاتب',
      imageUrl: 'https://i.pravatar.cc/150?img=52',
      rating: 4.6,
      reviewCount: 98,
      jobsCompleted: 134,
      hourlyRate: 20,
      location: 'جدة',
      isAvailable: true,
      skills: ['المكاتب', 'الزجاج', 'الأرضيات', 'المباني التجارية'],
      about: 'خبرة في تنظيف المكاتب والمنشآت التجارية بكفاءة عالية.',
    ),
  ];

  static List<BookingModel> get bookings => [
    BookingModel(
      id: 'b1',
      workerId: 'w1',
      workerName: 'ماريا سانتوس',
      workerImage: 'https://i.pravatar.cc/150?img=47',
      userId: 'u1',
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '10:00 صباحاً',
      service: 'تنظيف المنازل',
      total: 150,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.held,
      beforeAfterPhotos: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=300',
        'https://images.unsplash.com/photo-1527515637462-cff94eebd21f?w=300',
      ],
    ),
    BookingModel(
      id: 'b2',
      workerId: 'w2',
      workerName: 'فاطمة الحسن',
      workerImage: 'https://i.pravatar.cc/150?img=48',
      userId: 'u1',
      date: DateTime.now().subtract(const Duration(days: 5)),
      timeSlot: '02:00 مساءً',
      service: 'طبخ وتنظيف',
      total: 240,
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      beforeAfterPhotos: [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=300',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=300',
      ],
    ),
    BookingModel(
      id: 'b3',
      workerId: 'w4',
      workerName: 'نور خليل',
      workerImage: 'https://i.pravatar.cc/150?img=50',
      userId: 'u1',
      date: DateTime.now().add(const Duration(days: 7)),
      timeSlot: '09:00 صباحاً',
      service: 'رعاية كبار السن',
      total: 196,
      status: BookingStatus.pending,
      paymentStatus: PaymentStatus.unpaid,
    ),
  ];

  static List<Conversation> get conversations => [
    Conversation(
      id: 'c1',
      worker: workers[0],
      messages: [
        MessageModel(
          id: 'm1',
          senderId: 'w1',
          content: 'مرحباً! شكراً لحجزك معي. هل لديك أي متطلبات خاصة؟',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MessageModel(
          id: 'm2',
          senderId: 'u1',
          content: 'نعم، أحتاج إلى التركيز على المطبخ والحمامات من فضلك.',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 45),
          ),
        ),
        MessageModel(
          id: 'm3',
          senderId: 'w1',
          content: 'بالتأكيد! سأكون هناك الساعة 10 صباحاً 😊',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 30),
          ),
        ),
        MessageModel(
          id: 'm4',
          senderId: 'u1',
          content: 'ممتاز، شكراً جزيلاً!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: false,
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      worker: workers[1],
      messages: [
        MessageModel(
          id: 'm5',
          senderId: 'u1',
          content: 'هل يمكنك الطبخ لـ 6 أشخاص؟',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MessageModel(
          id: 'm6',
          senderId: 'w2',
          content: 'نعم بكل سهولة! ما نوع الأطباق التي تفضلونها؟',
          timestamp: DateTime.now().subtract(const Duration(hours: 23)),
          isRead: false,
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      worker: workers[3],
      messages: [
        MessageModel(
          id: 'm7',
          senderId: 'w4',
          content: 'أتطلع للعمل معكم. لديّ شهادة رعاية صحية معتمدة.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
  ];

  static const categories = [
    ('🏠', 'تنظيف'),
    ('👶', 'أطفال'),
    ('🍳', 'طبخ'),
    ('👴', 'مسنون'),
    ('✨', 'عميق'),
    ('🏢', 'مكاتب'),
  ];

  static const timeSlots = [
    '08:00 صباحاً',
    '09:00 صباحاً',
    '10:00 صباحاً',
    '11:00 صباحاً',
    '12:00 ظهراً',
    '01:00 مساءً',
    '02:00 مساءً',
    '03:00 مساءً',
    '04:00 مساءً',
    '05:00 مساءً',
  ];
}
