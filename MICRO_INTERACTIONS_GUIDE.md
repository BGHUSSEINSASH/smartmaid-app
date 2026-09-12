# 🎬 دليل تطبيق Micro-Interactions على الشاشات

## 📌 الاستخدامات الموصى به

### 1️⃣ شاشة البحث (Search Screen)
```dart
import '../widgets/micro_interactions.dart';

// في search results grid:
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemBuilder: (context, index) {
    final worker = workers[index];
    return Stack(
      children: [
        ProCard(
          onTap: () => navigateToDetail(worker),
          child: Column(
            children: [
              Image.network(worker.image),
              SizedBox(height: 8),
              Text(worker.name),
              Text(worker.category),
            ],
          ),
        ),
        // Like button مع animation
        Positioned(
          top: 8,
          right: 8,
          child: AnimatedLikeButton(
            initialLiked: isFavorite(worker.id),
            onChanged: (liked) => toggleFavorite(worker.id),
          ),
        ),
      ],
    );
  },
)
```

### 2️⃣ شاشة الحجز (Booking Screen)
```dart
// عنصر العداد لاختيار عدد الساعات
AnimatedCounter(
  initialValue: 1,
  minValue: 1,
  maxValue: 8,
  onChanged: (hours) => updateBookingHours(hours),
)

// عنصر السعر مع progress bar للـ discount
Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('السعر الأساسي'),
        Text('150 ريال'),
      ],
    ),
    SizedBox(height: 8),
    AnimatedProgressBar(
      value: discountPercentage / 100,
      activeColor: AppColors.success,
    ),
    Text('توفير 25%'),
  ],
)

// Toggle للاختيار بين خيارات
ToggleSwitchPro(
  initialValue: isWeekly,
  activeLabel: 'أسبوعي',
  inactiveLabel: 'لمرة واحدة',
  onChanged: (isWeekly) => updateBookingFrequency(isWeekly),
)
```

### 3️⃣ شاشة المحفظة (Wallet Screen)
```dart
// عرض الرصيد مع badge إشعار
Stack(
  children: [
    ProCard(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text('رصيدك الحالي'),
          Text('1,250 ريال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    ),
    // Badge مع عدد الإشعارات
    Positioned(
      top: 8,
      right: 8,
      child: AnimatedBadge(
        count: unreadNotifications,
        color: AppColors.warning,
      ),
    ),
  ],
)

// تاب switch بين الحسابات
AnimatedTabBar(
  tabs: ['المحفظة', 'البطاقات', 'التحويلات'],
  onTabChanged: (index) => setActiveTab(index),
  activeColor: AppColors.primary,
)
```

### 4️⃣ شاشة الإشعارات (Notifications Screen)
```dart
// قائمة الإشعارات مع swipe delete
ListView.builder(
  itemCount: notifications.length,
  itemBuilder: (context, index) {
    final notification = notifications[index];
    return SwipeActionListItem(
      onDelete: () => deleteNotification(notification.id),
      child: ProListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(notification.senderImage),
        ),
        title: notification.title,
        subtitle: notification.message,
        trailing: AnimatedBadge(
          count: notification.unreadCount,
        ),
        onTap: () => openNotification(notification),
      ),
    );
  },
)
```

### 5️⃣ شاشة الإعدادات (Settings Screen)
```dart
// Toggle لتفعيل الإشعارات
ProListTile(
  title: 'الإشعارات',
  subtitle: 'استقبل تحديثات تطبيق Smart Maid',
  trailing: ToggleSwitchPro(
    initialValue: settings.notificationsEnabled,
    onChanged: (enabled) => updateNotificationSettings(enabled),
  ),
)

// Progress bar لـ storage
Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('مساحة التخزين'),
        Text('${usedStorage.toStringAsFixed(1)}GB'),
      ],
    ),
    SizedBox(height: 8),
    AnimatedProgressBar(
      value: usedStorage / totalStorage,
      activeColor: AppColors.warning,
    ),
  ],
)

// FAB للإضافة
FloatingActionButtonPro(
  icon: Icons.add,
  label: 'جديد',
  onPressed: () => createNewItem(),
)
```

### 6️⃣ شاشة السلة (Cart Screen)
```dart
// عنصر في السلة مع عداد
ProListTile(
  leading: Image.network(item.image),
  title: item.name,
  subtitle: '${item.price} ريال',
  trailing: AnimatedCounter(
    initialValue: item.quantity,
    onChanged: (quantity) => updateQuantity(item.id, quantity),
  ),
  onTap: () => editItem(item),
)

// زر الدفع مع FAB
FloatingActionButtonPro(
  icon: Icons.payment,
  label: 'دفع',
  onPressed: () => proceedToPayment(),
  backgroundColor: AppColors.success,
)
```

### 7️⃣ شاشة الحالة (Status Screen)
```dart
// عرض مؤشر التقدم
Column(
  children: [
    AnimatedProgressBar(
      value: 0.65,
      activeColor: AppColors.info,
    ),
    SizedBox(height: 12),
    PageIndicatorPro(
      totalPages: 5,
      currentPage: currentStep,
      activeColor: AppColors.primary,
    ),
  ],
)

// عرض الحالة مع badge
StatusBadge(
  icon: Icons.check_circle,
  label: 'اكتمل 65%',
  color: AppColors.info,
)
```

### 8️⃣ شاشة التقييم (Review Screen)
```dart
// عرض عدد المراجعات
ProCard(
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('التقييمات'),
          AnimatedBadge(
            count: reviewCount,
            color: AppColors.warning,
          ),
        ],
      ),
      SizedBox(height: 12),
      // قائمة التقييمات مع like buttons
      ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Row(
            children: [
              Expanded(
                child: ProListTile(
                  title: review.author,
                  subtitle: review.text,
                  trailing: Icon(Icons.more_vert),
                ),
              ),
              AnimatedLikeButton(
                initialLiked: review.isLiked,
                onChanged: (liked) => likeReview(review.id),
              ),
            ],
          );
        },
      ),
    ],
  ),
)
```

### 9️⃣ شاشة اللائحة الأساسية (Base Navigation)
```dart
// في main_shell.dart:
// FAB للإضافة حجز جديد
FloatingActionButtonPro(
  icon: Icons.add_circle_outline,
  label: 'حجز',
  onPressed: () => Navigator.push(context, SlideInRoute(page: BookingScreen())),
  backgroundColor: AppColors.primary,
)

// Page indicator للـ tab الحالي
PageIndicatorPro(
  totalPages: 5,
  currentPage: selectedTabIndex,
)
```

---

## 🎯 Best Practices

### 1. Use Animations Sparingly
```dart
// ✅ Good - meaningful animations
AnimatedLikeButton()  // User action feedback
AnimatedCounter()      // State change indication

// ❌ Avoid - unnecessary animations
FadeTransition(
  opacity: _animation,
  child: Text('نص ثابت'),  // No user interaction
)
```

### 2. Performance
```dart
// ✅ Use const where possible
const FloatingActionButtonPro(...)

// ✅ Lazy load heavy lists
StaggeredListView(
  maxDelay: 300,  // Don't overdo it
  itemCount: items.length,
  itemBuilder: ...
)

// ❌ Avoid heavy computations in animations
// Put expensive operations outside animation builders
```

### 3. Consistency
```dart
// Use the same colors throughout
AnimatedLikeButton(
  activeColor: AppColors.primary,  // Consistent
)

ToggleSwitchPro(
  activeColor: AppColors.primary,  // Consistent
)
```

### 4. Accessibility
```dart
// ✅ Provide semantic labels
Semantics(
  label: 'إضافة عنصر جديد',
  child: FloatingActionButtonPro(...),
)

// ✅ Ensure touch targets are large enough
// Already handled in pro components (56px, 48px)
```

---

## 📊 Performance Metrics

### Recommended Animation Durations
```dart
// Quick feedback (200-300ms)
AnimatedCounter()           // 300ms
ToggleSwitchPro()           // 300ms

// Medium feedback (400-600ms)
AnimatedLikeButton()        // 600ms
AnimatedBadge()             // 400ms
PageIndicatorPro()          // 300ms

// Page transitions (350-400ms)
SlideInRoute()              // 400ms (+ 300ms reverse)
ScaleInRoute()              // 350ms (+ 250ms reverse)
```

---

## 🚀 Implementation Checklist

للشاشة الجديدة:

- [ ] Import `micro_interactions` و `pro_components`
- [ ] Replace static widgets مع animated versions
- [ ] Add `AnimatedLikeButton` لـ favorites
- [ ] Add `AnimatedCounter` للـ quantities
- [ ] Add `ToggleSwitchPro` للـ toggles
- [ ] Add `AnimatedBadge` للـ counters/notifications
- [ ] Add `SwipeActionListItem` لـ delete actions
- [ ] Use `FloatingActionButtonPro` للـ CTAs
- [ ] Test animations على device حقيقي
- [ ] Verify performance (60 FPS)
- [ ] Check accessibility

---

## 💡 نصائح

1. **لا تستخدم الكثير من الـ animations** - تركيز على الـ meaningful interactions
2. **اختبر على أجهزة حقيقية** - المحاكاة قد تخفي المشاكل
3. **راقب الـ frame rate** - يجب أن يكون 60 FPS دائماً
4. **تذكر الـ accessibility** - جعل الـ animations قابلة للتعطيل إن أمكن
5. **قلل الـ memory usage** - استخدم const و SingleTickerProviderStateMixin

---

**✅ تم إعداد دليل التطبيق الكامل!**
