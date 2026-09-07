// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فندق سيستم';

  @override
  String get appTagline => 'احجز، تحقّق، وادخل غرفتك من هاتفك.';

  @override
  String get foundationScreenTitle => 'الأساس ونظام التصميم';

  @override
  String get foundationScreenSubtitle =>
      'المرحلة صفر من التطبيق — بنية المشروع، السمة، الترجمة، وطبقة البيانات فقط. شاشات الميزات تأتي في المراحل التالية.';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get sectionTheme => 'المظهر';

  @override
  String get sectionBackendStatus => 'الاتصال بالخادم';

  @override
  String get sectionComponents => 'مكوّنات نظام التصميم';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String environmentLabel(String name) {
    return 'البيئة: $name';
  }

  @override
  String apiBaseUrlLabel(String url) {
    return 'عنوان الـ API: $url';
  }

  @override
  String get backendStatusOk => 'متصل';

  @override
  String get backendStatusDegraded => 'متذبذب';

  @override
  String get backendStatusDown => 'غير متصل';

  @override
  String backendStatusCheckedAt(String time) {
    return 'آخر فحص: $time';
  }

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionCheckAgain => 'افحص مجددًا';

  @override
  String get actionPrimaryExample => 'إجراء رئيسي';

  @override
  String get actionSecondaryExample => 'إجراء ثانوي';

  @override
  String get stateLoadingTitle => 'جارٍ التحميل…';

  @override
  String get stateEmptyTitle => 'لا يوجد شيء بعد';

  @override
  String get stateEmptySubtitle => 'عند توفّر بيانات لعرضها ستظهر هنا.';

  @override
  String get stateErrorTitle => 'حدث خطأ ما';

  @override
  String get errorGeneric => 'تعذّر إكمال الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork =>
      'يبدو أنك غير متصل بالإنترنت. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get errorTimeout =>
      'استغرق الطلب وقتًا طويلًا. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUnauthorized => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorServer => 'الخدمة غير متاحة مؤقتًا. يرجى المحاولة لاحقًا.';

  @override
  String get errorNotImplemented => 'هذا غير متاح في المرحلة صفر.';

  @override
  String get textFieldExampleLabel => 'الاسم الكامل';

  @override
  String get textFieldExampleHint => 'أدخل اسمك';
}
