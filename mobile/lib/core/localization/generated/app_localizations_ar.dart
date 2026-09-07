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

  @override
  String get entryTagline => 'إقامة بلا أوراق';

  @override
  String get entryHeadline => 'احجز، تحقّق، وادخل غرفتك من هاتفك';

  @override
  String get entrySubtext => 'دون طوابير ودون استقبال';

  @override
  String get entryStartAction => 'ابدأ الآن';

  @override
  String get entryLanguageSwitchLabel => 'اللغة';

  @override
  String get authPhoneTitle => 'تسجيل الدخول';

  @override
  String get authPhoneHeading => 'أدخل رقم جوالك';

  @override
  String get authPhoneBody =>
      'نحتاجه لتأكيد حجزك وإرسال رمز دخول غرفتك. لن نستخدمه لأي شيء آخر.';

  @override
  String get authPhoneFieldLabel => 'رقم الجوال';

  @override
  String get authPhoneFieldHint => '51 234 5678';

  @override
  String get authPhoneHelper => 'سنرسل رمز تحقق على هذا الرقم';

  @override
  String get authPhoneTerms =>
      'بالمتابعة أنت توافق على الشروط وسياسة الخصوصية.';

  @override
  String get authPhoneSubmit => 'إرسال رمز التحقق';

  @override
  String get authPhoneInvalid => 'أدخل رقم جوال صحيح';

  @override
  String get authOtpTitle => 'رمز التحقق';

  @override
  String get authOtpHeading => 'أدخل الرمز المرسل';

  @override
  String get authOtpChange => 'تغيير';

  @override
  String authOtpResendCountdown(String time) {
    return 'إعادة الإرسال خلال $time';
  }

  @override
  String get authOtpResendAction => 'إعادة إرسال الرمز';

  @override
  String get authOtpSubmit => 'تأكيد';

  @override
  String authOtpInvalidFormat(int length) {
    return 'أدخل الرمز المكوّن من $length أرقام';
  }

  @override
  String get authOtpErrorTitle => 'الرمز غير صحيح';

  @override
  String authOtpErrorBody(int count) {
    return 'المحاولات المتبقية: $count. تأكد من الرمز الأخير المرسل — الرموز السابقة تنتهي صلاحيتها فور إرسال رمز جديد.';
  }

  @override
  String get authOtpRetry => 'إعادة المحاولة';

  @override
  String get authOtpChangeNumber => 'تغيير رقم الجوال';

  @override
  String get authOtpLockedTitle => 'محاولات كثيرة';

  @override
  String get authOtpLockedBody =>
      'لحماية حسابك أوقفنا قبول الرموز. اطلب رمزًا جديدًا للمتابعة.';

  @override
  String get authProfileTitle => 'إكمال البيانات';

  @override
  String get authProfileBannerTitle => 'اكتب اسمك كما في الهوية';

  @override
  String get authProfileBannerBody =>
      'يقارن النظام اسمك بصورة بطاقتك عند التحقق. أي اختلاف قد يؤخر تسجيل دخولك.';

  @override
  String get authProfileNameLabel => 'الاسم الكامل';

  @override
  String get authProfileNameHint => 'محمود نبيل';

  @override
  String get authProfileEmailLabel => 'البريد الإلكتروني';

  @override
  String get authProfileEmailHint => 'name@example.com';

  @override
  String get authProfileSubmit => 'حفظ ومتابعة';

  @override
  String get authProfileNameInvalid => 'أدخل اسمك الكامل';

  @override
  String get authProfileEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get authSessionExpiredTitle => 'انتهت الجلسة';

  @override
  String get authSessionExpiredBannerTitle => 'انتهت جلستك';

  @override
  String get authSessionExpiredBannerBody =>
      'حجزك محفوظ ولم يُلغَ. سجّل دخولك مرة أخرى وسنعود إلى نفس الخطوة التي توقفت عندها.';

  @override
  String get authSessionExpiredSubmit => 'تسجيل الدخول';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String authDemoHint(String code) {
    return 'نسخة التطوير: رمز التحقق هو $code.';
  }
}
