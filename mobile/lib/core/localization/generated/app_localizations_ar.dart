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

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonReset => 'إعادة تعيين';

  @override
  String get commonClear => 'مسح';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonBack => 'رجوع';

  @override
  String get discoverGreeting => 'أهلاً بك';

  @override
  String discoverGreetingNamed(String name) {
    return 'أهلاً $name';
  }

  @override
  String get discoverSubtitle => 'اكتشف فنادق المجموعة';

  @override
  String get discoverSearchHint => 'ابحث عن فندق أو مدينة';

  @override
  String get discoverNotificationsTooltip => 'الإشعارات';

  @override
  String get discoverFeaturedSection => 'فنادق المجموعة';

  @override
  String get discoverEmptyTitle => 'لا توجد فنادق للعرض بعد';

  @override
  String get discoverEmptyBody => 'ستظهر فنادق المجموعة هنا بمجرد نشرها.';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchClearTooltip => 'مسح البحث';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فندقاً متاحاً',
      one: 'فندق واحد متاح',
      zero: 'لا فنادق متاحة',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResultsTitle => 'لا فنادق تطابق بحثك';

  @override
  String get searchNoResultsBody => 'جرّب مدينة أخرى أو امسح عوامل التصفية.';

  @override
  String get searchClearFilters => 'مسح عوامل التصفية';

  @override
  String get sortRecommended => 'المُوصى به';

  @override
  String get sortTopRated => 'الأعلى تقييماً';

  @override
  String get sortLowestPrice => 'الأوفر سعراً';

  @override
  String get sortTitle => 'ترتيب النتائج';

  @override
  String get sortHint => 'يبقى الترتيب مفعّلاً حتى تغيّره أو تعيد البحث.';

  @override
  String get sortApply => 'تطبيق الترتيب';

  @override
  String get sortActiveTag => 'مفعّل';

  @override
  String get filterTitle => 'تصفية النتائج';

  @override
  String filterMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فندقاً مطابقاً',
      one: 'فندق واحد مطابق',
      zero: 'لا فنادق مطابقة',
    );
    return '$_temp0';
  }

  @override
  String get filterHint => 'عدّل المعايير لتضييق النتائج.';

  @override
  String get filterCityLabel => 'المدينة';

  @override
  String get filterValueAll => 'الكل';

  @override
  String filterSelectedCount(int count) {
    return '$count مختارة';
  }

  @override
  String get filterPriceLabel => 'نطاق السعر';

  @override
  String get filterApply => 'تطبيق التصفية';

  @override
  String get filterClearAll => 'مسح الكل';

  @override
  String get filterCityPickerTitle => 'المدينة';

  @override
  String get filterCityPickerHint =>
      'يمكنك اختيار أكثر من مدينة. تُحدّث النتائج فور التطبيق.';

  @override
  String cityHotelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فنادق',
      one: 'فندق واحد',
    );
    return '$_temp0';
  }

  @override
  String priceRangeValue(int min, int max) {
    return '$min – $max ﷼';
  }

  @override
  String priceFrom(int amount) {
    return 'من $amount ﷼';
  }

  @override
  String pricePerNight(int amount) {
    return '$amount ﷼ / الليلة';
  }

  @override
  String priceStayTotal(int amount) {
    return '$amount ﷼ الإجمالي';
  }

  @override
  String hotelRatingValue(double rating) {
    final intl.NumberFormat ratingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String ratingString = ratingNumberFormat.format(rating);

    return '$ratingString';
  }

  @override
  String hotelReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مراجعة',
      one: 'مراجعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get hotelAvailable => 'متاحة';

  @override
  String get hotelUnavailable => 'غير متاحة حاليًا';

  @override
  String get hotelDetailReviews => 'التقييم والمراجعات';

  @override
  String get hotelReviewCleanliness => 'النظافة';

  @override
  String get hotelReviewCommunication => 'التواصل';

  @override
  String get hotelDetailAmenities => 'ما يقدّمه هذا الفندق';

  @override
  String hotelRoomTypeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أنواع غرف',
      one: 'نوع غرفة واحد',
    );
    return '$_temp0';
  }

  @override
  String hotelPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count',
    );
    return '$_temp0';
  }

  @override
  String get hotelSelectDates => 'اختيار التواريخ';

  @override
  String get amenityFreeWifi => 'واي فاي مجاني';

  @override
  String get amenityBreakfast => 'إفطار';

  @override
  String get amenityParking => 'موقف سيارات';

  @override
  String get amenityPool => 'مسبح';

  @override
  String get amenityGym => 'نادٍ رياضي';

  @override
  String get amenityFamilyRooms => 'غرف عائلية';

  @override
  String get amenityAirportShuttle => 'نقل المطار';

  @override
  String get amenityRoomService => 'خدمة الغرف';

  @override
  String get amenityAirConditioning => 'تكييف';

  @override
  String get amenityCityView => 'إطلالة على المدينة';

  @override
  String get amenityBalcony => 'شرفة';

  @override
  String get amenityKitchenette => 'مطبخ صغير';

  @override
  String get stayDatesTitle => 'اختيار تاريخ الإقامة';

  @override
  String get stayDatesCheckIn => 'تاريخ الوصول';

  @override
  String get stayDatesCheckOut => 'تاريخ المغادرة';

  @override
  String get stayDatesPick => 'اختر التاريخ';

  @override
  String get stayDatesClear => 'مسح التواريخ';

  @override
  String get stayDatesShowRooms => 'عرض الغرف المتاحة';

  @override
  String stayNights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ليالٍ',
      two: 'ليلتان',
      one: 'ليلة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get stayDatesErrorCheckoutBeforeCheckin =>
      'تاريخ المغادرة يجب أن يكون بعد تاريخ الوصول';

  @override
  String get stayDatesErrorPast => 'اختر تاريخًا من اليوم فأكثر';

  @override
  String get stayDatesEditDates => 'تعديل التواريخ';

  @override
  String get guestsTitle => 'عدد الضيوف';

  @override
  String get guestsAdults => 'بالغون';

  @override
  String get guestsChildren => 'أطفال';

  @override
  String get guestsConfirm => 'تأكيد الضيوف';

  @override
  String get stepperDecrease => 'إنقاص';

  @override
  String get stepperIncrease => 'زيادة';

  @override
  String guestsAdultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بالغين',
      two: 'بالغان',
      one: 'بالغ واحد',
    );
    return '$_temp0';
  }

  @override
  String guestsChildrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أطفال',
      two: 'طفلان',
      one: 'طفل واحد',
      zero: 'بدون أطفال',
    );
    return '$_temp0';
  }

  @override
  String get roomsTitle => 'الغرف المتاحة';

  @override
  String roomsAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متاحة',
      one: 'غرفة واحدة متاحة',
      zero: 'لا غرف متاحة',
    );
    return '$_temp0';
  }

  @override
  String get roomsSortLabel => 'الترتيب';

  @override
  String get roomsSortLowest => 'الأقل سعراً';

  @override
  String get roomsSortHighest => 'الأكثر سعراً';

  @override
  String roomOccupancy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      two: 'ضيفان',
      one: 'ضيف واحد',
    );
    return '$_temp0';
  }

  @override
  String get roomBreakfastIncluded => 'إفطار مجاني';

  @override
  String get roomFreeCancellation => 'إلغاء مجاني';

  @override
  String get roomNonRefundable => 'غير قابلة للاسترداد';

  @override
  String get roomSoldOut => 'غير متاحة في هذه التواريخ';

  @override
  String get roomsAllSoldOutTitle => 'جميع الغرف غير متاحة في هذه التواريخ';

  @override
  String get roomsAllSoldOutBody =>
      'جرّب تواريخ أخرى وسنعرض الغرف التي تتوفّر.';

  @override
  String get roomsNoResultsTitle => 'لا توجد غرف متاحة في التواريخ المحددة';

  @override
  String get roomsNoResultsBody => 'جرّب تغيير التواريخ أو تعديل عدد الضيوف.';

  @override
  String get roomsChangeDates => 'تغيير التواريخ';

  @override
  String get roomsChangeGuests => 'تعديل عدد الضيوف';
}
