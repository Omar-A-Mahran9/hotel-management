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
  String get errorNotImplemented =>
      'هذه الميزة غير متاحة بعد. يرجى المحاولة لاحقًا.';

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
  String get languageScreenTitle => 'اللغة';

  @override
  String get languageScreenHeading => 'اختر لغة التطبيق';

  @override
  String get languageScreenBody =>
      'يمكنك تغييرها لاحقاً من «حسابي». الواجهة مصمّمة بالعربية أولاً.';

  @override
  String get languageDefaultTag => 'افتراضي';

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
  String get navHome => 'الرئيسية';

  @override
  String get navBookings => 'حجوزاتي';

  @override
  String get navServices => 'الخدمات';

  @override
  String get navAccount => 'حسابي';

  @override
  String get navComingSoon => 'هذا القسم قيد الإنشاء وسيتوفّر في تحديث لاحق.';

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
  String get discoverSignIn => 'تسجيل الدخول';

  @override
  String get discoverFeaturedSection => 'فنادق المجموعة';

  @override
  String get discoverExploreRooms => 'استكشف الغرف';

  @override
  String get discoverUpcomingStay => 'إقامتك القادمة';

  @override
  String discoverSubtitleHotel(String hotel) {
    return 'اكتشف $hotel';
  }

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
  String get filterFacilitiesLabel => 'المرافق';

  @override
  String get filterRatingLabel => 'التقييم';

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
  String get priceFromLabel => 'من';

  @override
  String get priceNightSuffix => '/ ليلة';

  @override
  String get priceTotalSuffix => 'للإقامة';

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
  String get hotelReviewLocation => 'الموقع';

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
  String get hotelBookNow => 'احجز الآن';

  @override
  String hotelGuestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نزلاء',
      two: 'نزيلان',
      one: 'نزيل واحد',
    );
    return '$_temp0';
  }

  @override
  String roomAreaSqm(int area) {
    return '$area م²';
  }

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

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get calendarWeekdays => 'أحد,إثنين,ثلاثاء,أربعاء,خميس,جمعة,سبت';

  @override
  String stayDatesSelectedRange(String checkIn, String checkOut) {
    return '$checkIn – $checkOut';
  }

  @override
  String get stayDatesHintPickCheckIn => 'اختر تاريخ الوصول للبدء';

  @override
  String stayDatesHintPickCheckOut(String checkIn) {
    return '$checkIn · اختر تاريخ المغادرة';
  }

  @override
  String get stayDatesFieldPlaceholder => 'اختر التاريخ';

  @override
  String get roomSelect => 'اختيار';

  @override
  String get roomSelected => 'محدَّدة';

  @override
  String get roomViewDetails => 'عرض التفاصيل';

  @override
  String get roomDetailsTitle => 'تفاصيل الغرفة';

  @override
  String get roomBedType => 'السرير';

  @override
  String get roomCapacityLabel => 'تتّسع لـ';

  @override
  String get roomPolicyLabel => 'الإلغاء';

  @override
  String get roomPolicyRefundable => 'إلغاء مجاني';

  @override
  String get roomPolicyNonRefundable => 'غير قابلة للاسترداد';

  @override
  String get roomSelectThisRoom => 'اختيار هذه الغرفة';

  @override
  String get roomRemoveSelection => 'إلغاء الاختيار';

  @override
  String roomStayTotalLabel(int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights ليالٍ',
      two: 'ليلتين',
      one: 'ليلة واحدة',
    );
    return 'لـ $_temp0';
  }

  @override
  String get roomDetailAmenitiesHeading => 'المرافق';

  @override
  String get roomDetailCancellationHeading => 'سياسة الإلغاء';

  @override
  String get roomDetailStayHeading => 'إقامتك';

  @override
  String get roomSortTitle => 'ترتيب الغرف';

  @override
  String get roomSortApply => 'تطبيق الترتيب';

  @override
  String get roomSortActiveTag => 'مفعّل';

  @override
  String roomsSortTrigger(String label) {
    return 'الترتيب: $label';
  }

  @override
  String get roomsContinue => 'متابعة';

  @override
  String get roomsSelectPrompt => 'اختر غرفة للمتابعة';

  @override
  String get roomsSelectionClearedNotice =>
      'أُلغي اختيار الغرفة لتغيّر تفاصيل الإقامة. الرجاء اختيار غرفة من جديد.';

  @override
  String get reviewTitle => 'مراجعة اختيارك';

  @override
  String get reviewNotBookedNotice =>
      'لم يتم الحجز بعد. لا يزال بإمكانك تغيير التواريخ أو الضيوف أو الغرفة قبل خطوة الحجز.';

  @override
  String get reviewHotelLabel => 'الفندق';

  @override
  String get reviewRoomLabel => 'الغرفة';

  @override
  String get reviewStayLabel => 'الإقامة';

  @override
  String get reviewGuestsLabel => 'الضيوف';

  @override
  String get reviewCheckInLabel => 'تاريخ الوصول';

  @override
  String get reviewCheckOutLabel => 'تاريخ المغادرة';

  @override
  String get reviewPriceLabel => 'السعر';

  @override
  String reviewTotalLabel(int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights ليالٍ',
      two: 'ليلتين',
      one: 'ليلة واحدة',
    );
    return 'الإجمالي لـ $_temp0';
  }

  @override
  String get reviewChangeSelection => 'تغيير الاختيار';

  @override
  String get reviewNoSelectionTitle => 'لم تُختر غرفة';

  @override
  String get reviewNoSelectionBody => 'ارجع واختر غرفة لتظهر هنا.';

  @override
  String get reviewBackToRooms => 'العودة إلى الغرف';

  @override
  String get reviewSignInToConfirm => 'سجّل الدخول لتأكيد الحجز';

  @override
  String get reviewSignInHint =>
      'تحتاج حساباً لتأكيد هذا الحجز. التصفّح يبقى بلا تسجيل.';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get bookingDatesLabel => 'تواريخ الإقامة';

  @override
  String get bookingRoomSubtotal => 'قيمة الإقامة';

  @override
  String get bookingServiceFee => 'رسوم الخدمة';

  @override
  String get bookingServiceFeeNote =>
      'قيمة تقديرية للعرض — يؤكّد الفندق المبلغ النهائي.';

  @override
  String get bookingTotal => 'الإجمالي';

  @override
  String get bookingProceedToPayment => 'المتابعة للدفع';

  @override
  String get bookingRoomAvailable => 'متاحة';

  @override
  String get reservationConfirmCta => 'تأكيد الحجز';

  @override
  String get reservationConfirming => 'جارٍ التأكيد…';

  @override
  String get reservationConfirmHint =>
      'بالتأكيد، أنت تطلب هذه الغرفة للتواريخ أعلاه. لن يُخصم أي مبلغ الآن.';

  @override
  String get reservationCreateFailedTitle => 'تعذّر تأكيد حجزك';

  @override
  String get reservationStatusFieldLabel => 'الحالة';

  @override
  String get reservationStatusPending => 'قيد الانتظار';

  @override
  String get reservationStatusConfirmed => 'مؤكد';

  @override
  String get reservationStatusDepositHeld => 'تم حجز التأمين';

  @override
  String get reservationStatusVerified => 'تم التحقق';

  @override
  String get reservationStatusCheckedIn => 'تم تسجيل الدخول';

  @override
  String get reservationStatusInStay => 'أثناء الإقامة';

  @override
  String get reservationStatusCheckoutInProgress => 'جارٍ تسجيل المغادرة';

  @override
  String get reservationStatusCheckoutBlocked => 'المغادرة معلّقة';

  @override
  String get reservationStatusCheckedOut => 'تمت المغادرة';

  @override
  String get reservationStatusInvoiced => 'تمت الفوترة';

  @override
  String get reservationStatusCancelled => 'ملغى';

  @override
  String moneyAmount(String currency, int amount) {
    return '$currency $amount';
  }

  @override
  String get paymentReviewTitle => 'الدفع';

  @override
  String get paymentProcessingTitle => 'جارٍ معالجة الدفع';

  @override
  String get paymentResultTitle => 'الدفع';

  @override
  String get paymentReservationLabel => 'الحجز';

  @override
  String get paymentStatusFieldLabel => 'حالة الدفع';

  @override
  String get paymentAmountLabel => 'المبلغ';

  @override
  String get paymentPayNowCta => 'ادفع الآن';

  @override
  String get paymentHoldExplainer =>
      'يُحجَز مبلغ تأمين قابل للاسترداد لإقامتك. لن يُخصَم أي مبلغ الآن.';

  @override
  String get paymentProcessingBody => 'جارٍ تأكيد عملية الدفع…';

  @override
  String get paymentDoNotClose => 'يرجى إبقاء هذه الشاشة مفتوحة.';

  @override
  String get paymentAlreadyHeldTitle => 'تم حجز التأمين مسبقًا';

  @override
  String get paymentAlreadyHeldBody => 'حجز التأمين لهذا الحجز قائم بالفعل.';

  @override
  String get paymentSuccessTitle => 'تم تأكيد حجز التأمين';

  @override
  String get paymentSuccessBody =>
      'تم تأمين مبلغ التأمين. يمكنك المتابعة إلى التحقق من الهوية.';

  @override
  String get paymentPendingTitle => 'جارٍ معالجة الدفع';

  @override
  String get paymentPendingBody =>
      'لم يؤكد البنك الحجز بعد. يمكنك التحقق من الحالة بعد قليل.';

  @override
  String get paymentFailedTitle => 'تعذّر إتمام الدفع';

  @override
  String get paymentFailedBody => 'لم يُخصَم أي مبلغ. يمكنك المحاولة مرة أخرى.';

  @override
  String get paymentCancelledTitle => 'تم إلغاء الدفع';

  @override
  String get paymentExpiredTitle => 'انتهت صلاحية حجز التأمين';

  @override
  String get paymentRetryCta => 'حاول مرة أخرى';

  @override
  String get paymentBackToReservation => 'العودة إلى الحجز';

  @override
  String get paymentUnavailableTitle => 'الدفع غير متاح';

  @override
  String get paymentStatusNotStarted => 'لم يبدأ';

  @override
  String get paymentStatusHoldRequested => 'جارٍ التفويض';

  @override
  String get paymentStatusHoldActive => 'تم حجز التأمين';

  @override
  String get paymentStatusHoldFailed => 'فشل';

  @override
  String get paymentStatusCaptureRequested => 'جارٍ الخصم';

  @override
  String get paymentStatusCaptured => 'تم الخصم';

  @override
  String get paymentStatusCaptureFailed => 'فشل الخصم';

  @override
  String get paymentStatusFinalSettlementRequested => 'جارٍ التسوية';

  @override
  String get paymentStatusSettled => 'تمت التسوية';

  @override
  String get paymentStatusSettlementFailed => 'فشلت التسوية';

  @override
  String get paymentStatusCancelled => 'ملغى';

  @override
  String get paymentStatusExpired => 'منتهٍ';

  @override
  String get paymentStatusRefundRequested => 'استرداد قيد المعالجة';

  @override
  String get paymentStatusRefunded => 'تم الاسترداد';

  @override
  String get paymentStatusRefundFailed => 'فشل الاسترداد';

  @override
  String get identityVerificationTitle => 'التحقق من الهوية';

  @override
  String get identityVerificationResultTitle => 'التحقق من الهوية';

  @override
  String get identityVerifyCta => 'تحقّق من الهوية';

  @override
  String get identityStepDocument => 'المستند';

  @override
  String get identityStepSelfie => 'صورة ذاتية';

  @override
  String get identityStepResult => 'النتيجة';

  @override
  String get identityDocumentStepTitle => 'ارفع مستند هويتك';

  @override
  String get identityDocumentStepBody =>
      'استخدم جواز السفر أو الهوية الوطنية أو تصريح الإقامة. تأكد من ظهور المستند كاملًا وواضحًا.';

  @override
  String get identityDocumentTypePassport => 'جواز السفر';

  @override
  String get identityDocumentTypeNationalId => 'الهوية الوطنية';

  @override
  String get identityDocumentTypeResidencePermit => 'تصريح الإقامة';

  @override
  String get identityDocumentTypeLabel => 'نوع المستند';

  @override
  String get identityDocumentCaptureCta => 'أضف صورة المستند';

  @override
  String get identityDocumentCapturedLabel => 'تمت إضافة صورة المستند';

  @override
  String get identityDocumentSubmitCta => 'المتابعة إلى الصورة الذاتية';

  @override
  String get identitySelfieStepTitle => 'التقط صورة ذاتية';

  @override
  String get identitySelfieStepBody =>
      'انظر مباشرة إلى الكاميرا في إضاءة جيدة. نطابق صورتك الذاتية مع صورة هويتك.';

  @override
  String get identitySelfieCaptureCta => 'أضف صورة ذاتية';

  @override
  String get identitySelfieCapturedLabel => 'تمت إضافة الصورة الذاتية';

  @override
  String get identitySelfieSubmitCta => 'إرسال للتحقق';

  @override
  String get identityProcessingTitle => 'جارٍ التحقق من هويتك';

  @override
  String get identityProcessingBody => 'جارٍ مطابقة صورتك الذاتية مع مستندك…';

  @override
  String get identityApprovedTitle => 'تم التحقق من الهوية';

  @override
  String get identityApprovedBody => 'تم تأكيد هويتك. أنت جاهز لتسجيل الدخول.';

  @override
  String get identityManualReviewTitle => 'المراجعة اليدوية قيد التنفيذ';

  @override
  String get identityManualReviewBody =>
      'يقوم فريقنا بمراجعة مستنداتك. تستغرق هذه العملية وقتًا قصيرًا عادةً — سنُعلمك عند اكتمالها.';

  @override
  String get identityRetryTitle => 'لنجرب ذلك مرة أخرى';

  @override
  String get identityRetryBody =>
      'لم نتمكن من التحقق من هويتك من تلك الصور. يرجى إعادة التقاطها وإرسالها مجددًا.';

  @override
  String get identityRetryCta => 'حاول مرة أخرى';

  @override
  String get identityRejectedTitle => 'لم تتم الموافقة على التحقق';

  @override
  String get identityRejectedBody =>
      'لم يتمكن فريقنا من الموافقة على التحقق من هويتك. يرجى التواصل مع مكتب الاستقبال للمساعدة.';

  @override
  String get identityRejectedRetryBody =>
      'لم يتمكن فريقنا من الموافقة على التحقق من هويتك. يمكنك إرسال صور جديدة والمحاولة مرة أخرى.';

  @override
  String identityAttemptCount(int count) {
    return 'المحاولة $count';
  }

  @override
  String get identityBackToReservation => 'العودة إلى الحجز';

  @override
  String get identityViewResultCta => 'عرض النتيجة';

  @override
  String get identityUnavailableTitle => 'التحقق غير متاح';

  @override
  String get identityStatusNotStarted => 'لم يبدأ';

  @override
  String get identityStatusDocumentUploaded => 'تم رفع المستند';

  @override
  String get identityStatusSelfieCaptured => 'تم التقاط الصورة الذاتية';

  @override
  String get identityStatusMatchingInProgress => 'جارٍ المطابقة';

  @override
  String get identityStatusAutoApproved => 'تم التحقق';

  @override
  String get identityStatusPendingManualReview => 'قيد المراجعة';

  @override
  String get identityStatusStaffApproved => 'تم التحقق';

  @override
  String get identityStatusStaffRejected => 'غير موافق عليه';

  @override
  String get identityStatusRetryAllowed => 'يلزم إعادة المحاولة';

  @override
  String get reservationCheckInCta => 'تسجيل الدخول';

  @override
  String get checkInTitle => 'تسجيل الدخول';

  @override
  String get checkInProcessingTitle => 'جارٍ تسجيل دخولك';

  @override
  String get accessTitle => 'الدخول إلى الغرفة';

  @override
  String get checkInReadyTitle => 'جاهز لتسجيل الدخول';

  @override
  String get checkInReadyBody =>
      'تم التحقق من حجزك. سجّل الدخول للحصول على رقم غرفتك ورمز الدخول.';

  @override
  String get checkInNotReadyTitle => 'لست جاهزًا لتسجيل الدخول بعد';

  @override
  String get checkInNotReadyBody => 'أكمل الدفع والتحقق من الهوية أولاً.';

  @override
  String get checkInUnavailableTitle => 'تسجيل الدخول غير متاح';

  @override
  String get checkInAlreadyDoneTitle => 'لقد سجّلت دخولك بالفعل';

  @override
  String get checkInCta => 'سجّل الدخول الآن';

  @override
  String get checkInProcessingBody => 'جارٍ إصدار مفتاح غرفتك الرقمي…';

  @override
  String get checkInDoNotClose => 'يرجى إبقاء هذه الشاشة مفتوحة.';

  @override
  String get checkInFailedTitle => 'لم يكتمل تسجيل الدخول';

  @override
  String get checkInFailedBody =>
      'تعذّر إصدار مفتاح غرفتك. يمكنك المحاولة مرة أخرى.';

  @override
  String get checkInPendingTitle => 'أوشكت على الانتهاء';

  @override
  String get checkInPendingBody =>
      'يقوم مكتب الاستقبال بإنهاء تسجيل دخولك. تحقق مرة أخرى بعد قليل.';

  @override
  String get checkInRetryCta => 'حاول مرة أخرى';

  @override
  String get accessCheckedInTitle => 'تم تسجيل دخولك';

  @override
  String get accessRoomNumberLabel => 'رقم الغرفة';

  @override
  String get accessEntryCodeLabel => 'رمز الدخول';

  @override
  String accessExpiresLabel(String date) {
    return 'ساري حتى انتهاء إقامتك · $date';
  }

  @override
  String get accessHelpBanner => 'لم يعمل الرمز؟ تواصل مع الاستقبال.';

  @override
  String get accessNotIssuedTitle => 'لا يوجد مفتاح غرفة بعد';

  @override
  String get accessNotIssuedBody =>
      'سجّل الدخول للحصول على مفتاح غرفتك الرقمي.';

  @override
  String get accessRevokedTitle => 'تم إلغاء مفتاح الغرفة';

  @override
  String get accessRevokedBody =>
      'لم يعد مفتاح الغرفة هذا نشطًا. تواصل مع الاستقبال إذا احتجت للمساعدة.';

  @override
  String get accessExpiredTitle => 'انتهت صلاحية مفتاح الغرفة';

  @override
  String get accessExpiredBody =>
      'انتهت إقامتك، لذا لم يعد مفتاح الغرفة هذا يعمل.';

  @override
  String get accessFailedTitle => 'مفتاح الغرفة غير متاح';

  @override
  String get accessUnavailableTitle => 'الدخول غير متاح';

  @override
  String get accessBackToReservation => 'العودة إلى الحجز';

  @override
  String get accessStatusNotIssued => 'لم يُصدر';

  @override
  String get accessStatusIssueRequested => 'جارٍ الإصدار';

  @override
  String get accessStatusActive => 'نشط';

  @override
  String get accessStatusFailed => 'فشل';

  @override
  String get accessStatusRevokeRequested => 'جارٍ الإلغاء';

  @override
  String get accessStatusRevoked => 'ملغى';

  @override
  String get accessStatusExpired => 'منتهٍ';

  @override
  String get servicesTitle => 'خدمات الفندق';

  @override
  String get servicesIntroBanner =>
      'اطلب ما تحتاجه من غرفتك. تصل الطلبات إلى الاستقبال مباشرة.';

  @override
  String get servicesEmptyTitle => 'لا توجد خدمات متاحة';

  @override
  String get servicesEmptyBody => 'لم ينشر هذا الفندق أي خدمات بعد.';

  @override
  String get servicesUnavailableTitle => 'الخدمات غير متاحة';

  @override
  String get serviceUncategorised => 'خدمات أخرى';

  @override
  String get serviceFreeLabel => 'مشمول';

  @override
  String serviceEstimatedMinutes(int count) {
    return '~$count دقيقة';
  }

  @override
  String get serviceDetailTitle => 'الخدمة';

  @override
  String get serviceQuantityLabel => 'الكمية';

  @override
  String get serviceNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get serviceNotesHint => 'أي شيء يجب أن يعرفه الفريق';

  @override
  String get serviceRequestCta => 'اطلب هذه الخدمة';

  @override
  String get serviceRequestingCta => 'جارٍ الإرسال…';

  @override
  String get serviceEstimatedTotalLabel => 'الإجمالي المقدّر';

  @override
  String get serviceChargeNote =>
      'تُضاف أي رسوم إلى حساب غرفتك وتُسوّى عند المغادرة.';

  @override
  String get serviceRequestFailedTitle => 'تعذّر إرسال طلبك';

  @override
  String get myRequestsTitle => 'طلباتي';

  @override
  String get myRequestsIntroBanner =>
      'تابع حالة كل طلب. يمكنك إلغاء الطلب قبل أن يبدأ الفريق تنفيذه.';

  @override
  String get myRequestsEmptyTitle => 'لا توجد طلبات بعد';

  @override
  String get myRequestsEmptyBody => 'اطلب خدمة وستظهر هنا.';

  @override
  String get newRequestCta => 'طلب جديد';

  @override
  String get serviceOrderDetailTitle => 'تفاصيل الطلب';

  @override
  String get serviceOrderRequestedAtLabel => 'تاريخ الطلب';

  @override
  String get serviceOrderConfirmedAtLabel => 'تاريخ القبول';

  @override
  String get serviceCancelCta => 'إلغاء الطلب';

  @override
  String get serviceCancelConfirmTitle => 'إلغاء هذا الطلب؟';

  @override
  String get serviceCancelConfirmBody =>
      'لم يبدأ الفريق تنفيذ هذا الطلب بعد، لذا لا يزال بالإمكان إلغاؤه.';

  @override
  String get serviceCancelConfirmCta => 'نعم، إلغاء';

  @override
  String get serviceCancelKeepCta => 'الإبقاء على الطلب';

  @override
  String get serviceCancelNotAllowed => 'لم يعد بالإمكان إلغاء هذا الطلب.';

  @override
  String get serviceContactReception => 'تواصل مع الاستقبال';

  @override
  String get serviceContactReceptionHint =>
      'اتصل بالاستقبال من هاتف غرفتك أو من مكتب الاستقبال للمساعدة في هذا الطلب.';

  @override
  String get serviceStatusRequested => 'قيد الانتظار';

  @override
  String get serviceStatusConfirmed => 'مقبول';

  @override
  String get serviceStatusFulfilled => 'مكتمل';

  @override
  String get serviceStatusCancelled => 'ملغى';

  @override
  String get checkoutTitle => 'المغادرة';

  @override
  String get checkoutProcessingTitle => 'جارٍ إتمام المغادرة';

  @override
  String get checkoutCompleteTitle => 'ملخص إقامتك';

  @override
  String get invoiceTitle => 'الفاتورة';

  @override
  String get checkoutReadyTitle => 'جاهز للمغادرة';

  @override
  String get checkoutReadyBody => 'لا مهام معلّقة.';

  @override
  String get checkoutNotReadyTitle => 'المغادرة غير متاحة بعد';

  @override
  String get checkoutNotReadyBody => 'يمكنك تسجيل المغادرة بعد أن تبدأ إقامتك.';

  @override
  String get checkoutUnavailableTitle => 'المغادرة غير متاحة';

  @override
  String get folioSummaryTitle => 'ملخص الرسوم';

  @override
  String get folioAccommodationLine => 'قيمة الإقامة';

  @override
  String get folioServiceLine => 'رسوم الخدمة';

  @override
  String get folioTotalLabel => 'الإجمالي';

  @override
  String get folioPaidLabel => 'المدفوع مسبقًا';

  @override
  String get folioOutstandingLabel => 'المبلغ المستحق الآن';

  @override
  String get checkoutSettleNote =>
      'يُخصم المبلغ المستحق دفعة واحدة من بطاقتك المسجّلة، وتُرسل فاتورتك إلكترونياً.';

  @override
  String get checkoutCompleteCta => 'إتمام المغادرة';

  @override
  String get checkoutProcessingBody => 'جارٍ تسوية حسابك…';

  @override
  String get checkoutDoNotClose => 'يرجى إبقاء هذه الشاشة مفتوحة.';

  @override
  String get checkoutDoneTitle => 'شكراً لإقامتك';

  @override
  String get checkoutDoneBody => 'تمت تسوية حسابك وفاتورتك جاهزة.';

  @override
  String get checkoutPendingTitle => 'جارٍ معالجة التسوية';

  @override
  String get checkoutPendingBody =>
      'لم يؤكد البنك الدفع بعد. تحقق من الحالة مرة أخرى بعد قليل.';

  @override
  String get checkoutFailedTitle => 'لم تكتمل التسوية';

  @override
  String get checkoutFailedBody => 'لم يُخصم أي مبلغ. يمكنك المحاولة مرة أخرى.';

  @override
  String get checkoutRetryCta => 'حاول مرة أخرى';

  @override
  String get checkoutViewInvoiceCta => 'عرض الفاتورة';

  @override
  String get checkoutDoneCta => 'تم';

  @override
  String get checkoutStatusInProgress => 'قيد التنفيذ';

  @override
  String get checkoutStatusAwaitingSettlement => 'بانتظار التسوية';

  @override
  String get checkoutStatusSettlementFailed => 'فشلت التسوية';

  @override
  String get checkoutStatusCompleted => 'مكتمل';

  @override
  String get invoiceIssuedBannerTitle => 'صدرت فاتورتك الإلكترونية';

  @override
  String get invoiceIssuedBannerBody =>
      'أُرسلت إلى بريدك الإلكتروني وهي محفوظة هنا دائماً — لا فاتورة ورقية.';

  @override
  String get invoiceNumberLabel => 'رقم الفاتورة';

  @override
  String get invoiceIssuedLabel => 'تاريخ الإصدار';

  @override
  String get invoiceItemsTitle => 'البنود';

  @override
  String get invoiceSubtotalLabel => 'المجموع الفرعي';

  @override
  String get invoicePaymentsLabel => 'المدفوعات';

  @override
  String get invoiceOutstandingLabel => 'المتبقي';

  @override
  String get invoiceSettledTag => 'مُسدّدة بالكامل';

  @override
  String get invoiceNotReadyTitle => 'لا توجد فاتورة بعد';

  @override
  String get invoiceNotReadyBody => 'ستظهر فاتورتك هنا بعد تسجيل مغادرتك.';

  @override
  String get invoiceUnavailableTitle => 'الفاتورة غير متاحة';

  @override
  String get reservationLoyaltyCta => 'الولاء والنقاط';

  @override
  String get reservationReviewCta => 'أضف تقييماً';

  @override
  String get reservationViewReviewCta => 'عرض تقييمك';

  @override
  String get loyaltyTitle => 'الولاء';

  @override
  String get loyaltyUnavailableTitle => 'الولاء غير متاح';

  @override
  String get loyaltyBalanceLabel => 'رصيد النقاط';

  @override
  String loyaltyPointsValue(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points نقطة',
      one: 'نقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyGroupWideNote => 'نقاطك صالحة في جميع فنادق المجموعة.';

  @override
  String get loyaltyProgramOffTitle => 'برنامج الولاء غير مُفعّل';

  @override
  String get loyaltyProgramOffBody =>
      'لم تُفعّل مجموعة الفنادق كسب النقاط بعد. لا يوجد إجراء مطلوب هنا حالياً.';

  @override
  String get loyaltyEarnCta => 'اكسب نقاطاً عن هذه الإقامة';

  @override
  String get loyaltyEarningCta => 'جارٍ إضافة نقاطك…';

  @override
  String get loyaltyEarnedTitle => 'تمت إضافة النقاط';

  @override
  String loyaltyEarnedBody(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'أُضيفت $points نقطة إلى رصيدك.',
      one: 'أُضيفت نقطة واحدة إلى رصيدك.',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyAlreadyEarnedTitle => 'النقاط مُضافة بالفعل';

  @override
  String get loyaltyAlreadyEarnedBody =>
      'لقد كسبت نقاطاً عن هذه الإقامة بالفعل.';

  @override
  String get loyaltyNotEligibleTitle => 'غير مؤهّل بعد';

  @override
  String get loyaltyNotEligibleBody => 'تُضاف النقاط بعد اكتمال إقامتك.';

  @override
  String get loyaltyNothingToEarnTitle => 'لا نقاط لإضافتها';

  @override
  String get loyaltyNothingToEarnBody =>
      'لا يوجد لهذه الإقامة مبلغ يكسب نقاطاً.';

  @override
  String get loyaltyHistoryTitle => 'سجل النقاط';

  @override
  String get loyaltyHistoryNote =>
      'سجل نقاطك الكامل محفوظ لدى مجموعة الفنادق. هذه نسخة للعرض فقط.';

  @override
  String get loyaltyHistoryEmptyTitle => 'لا نشاط نقاط بعد';

  @override
  String get loyaltyHistoryEmptyBody =>
      'ستظهر هنا النقاط التي تكسبها وتستبدلها.';

  @override
  String loyaltyPointsAdded(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '+$points نقطة',
      one: '+نقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String loyaltyPointsRemoved(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '-$points نقطة',
      one: '-نقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyTxThisStay => 'هذه الإقامة';

  @override
  String get loyaltyTxEarnLabel => 'مكتسبة';

  @override
  String get loyaltyTxRedeemLabel => 'مُستبدلة';

  @override
  String get loyaltyTxReverseLabel => 'معكوسة';

  @override
  String get loyaltyTxAdjustLabel => 'تسوية';

  @override
  String get loyaltyTxExpireLabel => 'منتهية';

  @override
  String get loyaltyRedeemCta => 'استبدل النقاط';

  @override
  String get loyaltyRedeemTitle => 'استبدال النقاط';

  @override
  String get loyaltyRedeemSubmitCta => 'استبدال';

  @override
  String get loyaltyRedeemingCta => 'جارٍ الاستبدال…';

  @override
  String get loyaltyRedeemAmountLabel => 'النقاط المراد استبدالها';

  @override
  String get loyaltyRedeemNote =>
      'تُستبدل النقاط مقابل هذا الحجز. تؤكد مجموعة الفنادق القيمة النهائية.';

  @override
  String loyaltyRedeemMax(int points) {
    return 'استخدم الحد الأقصى ($points)';
  }

  @override
  String get loyaltyRedeemedTitle => 'تم استبدال النقاط';

  @override
  String loyaltyRedeemedBody(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'تم استبدال $points نقطة مقابل هذا الحجز.',
      one: 'تم استبدال نقطة واحدة مقابل هذا الحجز.',
    );
    return '$_temp0';
  }

  @override
  String loyaltyRedeemedValueNote(String value, String currency) {
    return 'هذا يعادل نحو $value $currency خصماً على هذا الحجز.';
  }

  @override
  String get loyaltyRedeemNotEligibleTitle => 'لا يمكن الاستبدال على هذا الحجز';

  @override
  String get loyaltyRedeemNotEligibleBody =>
      'لا يمكن استبدال النقاط إلا مقابل حجز نشط.';

  @override
  String get loyaltyAlreadyRedeemedTitle => 'مُستبدلة بالفعل';

  @override
  String get loyaltyAlreadyRedeemedBody => 'سبق استبدال نقاط مقابل هذا الحجز.';

  @override
  String get loyaltyAlreadyRedeemedDifferentBody =>
      'سبق استبدال عدد مختلف من النقاط مقابل هذا الحجز.';

  @override
  String get loyaltyInsufficientTitle => 'النقاط غير كافية';

  @override
  String get loyaltyInsufficientBody => 'ليس لديك نقاط كافية لهذا المبلغ.';

  @override
  String get loyaltyInvalidAmountBody => 'اختر عدد النقاط المراد استبدالها.';

  @override
  String get reviewFormTitle => 'أضف تقييماً';

  @override
  String get reviewFormPrompt => 'كيف كانت إقامتك؟';

  @override
  String get reviewResultTitle => 'تقييمك';

  @override
  String get reviewProcessingTitle => 'جارٍ إرسال تقييمك';

  @override
  String get reviewProcessingBody => 'جارٍ إرسال تقييمك…';

  @override
  String get reviewDoNotClose =>
      'لن يستغرق هذا سوى لحظة. من فضلك لا تغلق التطبيق.';

  @override
  String get reviewRatingRequired => 'اختر تقييماً من 1 إلى 5 نجوم.';

  @override
  String reviewStarsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نجوم',
      one: 'نجمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get reviewTextLabel => 'تقييمك (اختياري)';

  @override
  String get reviewTextHint => 'أخبر النزلاء الآخرين عن إقامتك';

  @override
  String get reviewSubmitCta => 'إرسال التقييم';

  @override
  String get reviewSubmittingCta => 'جارٍ الإرسال…';

  @override
  String get reviewYourRatingLabel => 'تقييمك';

  @override
  String get reviewBackToReservation => 'العودة إلى الحجز';

  @override
  String get reviewUnavailableTitle => 'التقييمات غير متاحة';

  @override
  String get reviewNotEligibleTitle => 'لا يمكنك تقييم هذه الإقامة';

  @override
  String get reviewNotEligibleBody => 'تُفتح التقييمات بعد اكتمال إقامتك.';

  @override
  String get reviewSubmittedTitle => 'شكراً لتقييمك';

  @override
  String get reviewPublishedBody => 'تم نشر تقييمك.';

  @override
  String get reviewPendingModerationBody =>
      'تم استلام تقييمك وهو قيد المراجعة السريعة من فريقنا قبل نشره.';

  @override
  String get reviewAlreadyTitle => 'لقد قيّمت هذه الإقامة بالفعل';

  @override
  String get reviewAlreadyBody =>
      'تقييم واحد لكل إقامة. يظهر تقييمك الحالي أدناه.';

  @override
  String get reviewRejectedTitle => 'لم يُنشر هذا التقييم';

  @override
  String get reviewRejectedBody => 'لم يجتز تقييمك مراجعتنا ولم يُنشر.';

  @override
  String get reviewInvalidRatingTitle => 'التقييم خارج النطاق';

  @override
  String get reviewInvalidRatingBody => 'يجب أن يكون التقييم بين 1 و5 نجوم.';

  @override
  String get reviewFailedTitle => 'تعذّر إرسال تقييمك';

  @override
  String get reviewStatusPending => 'قيد المراجعة';

  @override
  String get reviewStatusPublished => 'منشور';

  @override
  String get reviewStatusRejected => 'غير منشور';

  @override
  String get bookingsPillCurrent => 'الحالية';

  @override
  String get bookingsPillUpcoming => 'القادمة';

  @override
  String get bookingsPillPast => 'السابقة';

  @override
  String get bookingsPastTitle => 'إقامات سابقة';

  @override
  String get bookingsSectionOngoingStay => 'إقامة جارية';

  @override
  String get bookingsSectionUpcoming => 'حجوزات قادمة';

  @override
  String get bookingsEmptyTitle => 'لا توجد حجوزات';

  @override
  String get bookingsEmptyBody => 'ستظهر حجوزاتك هنا بمجرد إتمام أول حجز.';

  @override
  String get bookingStatusPending => 'قيد الانتظار';

  @override
  String get bookingStatusConfirmed => 'مؤكد';

  @override
  String get bookingStatusCheckedIn => 'تم تسجيل الدخول';

  @override
  String get bookingStatusCompleted => 'مكتملة';

  @override
  String get bookingStatusCancelled => 'ملغاة';

  @override
  String get bookingDetailTitle => 'تفاصيل الحجز';

  @override
  String get bookingPaymentStatusHeading => 'حالة الدفع';

  @override
  String get bookingCancellationPolicyHeading => 'سياسة الإلغاء';

  @override
  String get bookingCancellationPolicyBody =>
      'إلغاء مجاني حتى 24 ساعة قبل الوصول. بعدها يُخصم مبلغ التأمين.';

  @override
  String get bookingPendingRowTitle => 'بانتظار إتمام الدفع';

  @override
  String get bookingPendingRowSubtitle => 'لم يكتمل';

  @override
  String get bookingAutoCancelRowTitle => 'يُلغى الحجز تلقائياً خلال 30 دقيقة';

  @override
  String get bookingRoomHeldRowTitle => 'الغرفة محجوزة مؤقتاً';

  @override
  String get bookingRoomHeldRowSubtitle => 'غير مؤكدة';

  @override
  String get bookingDepositHeldRowTitle => 'تم حجز مبلغ التأمين';

  @override
  String get bookingDepositHeldRowSubtitle => 'دون خصم فعلي';

  @override
  String get bookingDeductedAtCheckinRowTitle => 'يُخصم عند تسجيل الدخول';

  @override
  String get bookingExtrasChargedOnceRowTitle =>
      'تُجمع المصاريف الإضافية عند المغادرة';

  @override
  String get bookingExtrasChargedOnceRowSubtitle => 'دفعة واحدة';

  @override
  String get bookingIdentityVerifiedRowTitle => 'تم التحقق من هويتك';

  @override
  String get bookingIdentityVerifiedRowSubtitle => 'مكتمل';

  @override
  String get bookingCheckInAvailableRowTitle => 'تسجيل الدخول متاح من';

  @override
  String get bookingDepositAmountHeldRowTitle => 'مبلغ التأمين محجوز';

  @override
  String get bookingOngoingStayRowTitle => 'إقامة جارية';

  @override
  String bookingRoomLabel(String number) {
    return 'غرفة $number';
  }

  @override
  String get bookingDepartureRowTitle => 'المغادرة';

  @override
  String get bookingExtraChargesRowTitle => 'المصاريف الإضافية';

  @override
  String get bookingCancelledRowTitle => 'ألغي الحجز';

  @override
  String get bookingDepositRefundRowTitle => 'استرداد مبلغ التأمين';

  @override
  String get bookingDepositRefundRowSubtitle => 'خلال 3 أيام عمل';

  @override
  String get bookingCancellationFeeRowTitle => 'رسوم الإلغاء';

  @override
  String get bookingCancellationFeeNone => 'لا توجد';

  @override
  String get bookingStayEndedRowTitle => 'انتهت الإقامة';

  @override
  String get bookingTotalPaidRowTitle => 'الإجمالي المدفوع';

  @override
  String get bookingInvoiceReadyRowTitle => 'الفاتورة الإلكترونية';

  @override
  String get bookingInvoiceReadyRowSubtitle => 'جاهزة';

  @override
  String get bookingCtaContinuePayment => 'متابعة الدفع';

  @override
  String get bookingCtaCancelReservation => 'إلغاء الحجز';

  @override
  String get bookingCtaVerifyIdentity => 'التحقق من الهوية';

  @override
  String get bookingCtaDigitalCheckIn => 'تسجيل الدخول الرقمي';

  @override
  String get bookingCtaMyCurrentStay => 'إقامتي الحالية';

  @override
  String get bookingCtaShowAccessCode => 'عرض رمز الدخول';

  @override
  String get bookingCtaBookAgain => 'احجز مرة أخرى';

  @override
  String get bookingCtaViewInvoice => 'عرض الفاتورة';

  @override
  String get bookingCancelConfirmTitle => 'إلغاء هذا الحجز؟';

  @override
  String get bookingCancelConfirmBody =>
      'لا يمكن التراجع عن هذا الإجراء. سيُسترد مبلغ التأمين وفق سياسة الإلغاء.';

  @override
  String get bookingCancelKeepCta => 'الاحتفاظ بالحجز';

  @override
  String get bookingCancelConfirmCta => 'إلغاء الحجز';

  @override
  String get bookingNotFoundTitle => 'الحجز غير موجود';

  @override
  String get accountTitle => 'حسابي';

  @override
  String get accountLoyaltyProgramTitle => 'برنامج الولاء';

  @override
  String get accountLoyaltyPointsSuffix => 'نقطة';

  @override
  String get accountLoyaltyDescription =>
      'نقاطك تُجمع من كل فنادق المجموعة وتُصرف في أي فرع.';

  @override
  String get accountLoyaltyPerNightLabel => 'لكل ليلة';

  @override
  String get accountTrustedGuestTitle => 'نزيل موثوق';

  @override
  String get accountTrustedGuestBody =>
      'لن يُطلب منك رفع صور الهوية مرة أخرى في أي فندق آخر بالمجموعة.';

  @override
  String get accountPreviousStaysLabel => 'إقامات سابقة';

  @override
  String get accountPreferencesLabel => 'تفضيلاتي';

  @override
  String get accountPreferencesEmpty => 'لم تُحدد بعد';

  @override
  String get accountPrivacyLabel => 'الخصوصية وبياناتي';

  @override
  String get accountHelpSupportLabel => 'المساعدة والدعم';

  @override
  String get stayHomeTitle => 'إقامتك الحالية';

  @override
  String get stayHomeRoomLabel => 'غرفتك';

  @override
  String get stayHomeServicesHeading => 'الخدمات';

  @override
  String get stayHomeRoomService => 'خدمة الغرف';

  @override
  String get stayHomeRoomCleaning => 'تنظيف الغرفة';

  @override
  String get stayHomeExtendStay => 'تمديد الإقامة';

  @override
  String get stayHomeReportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get stayHomeExtraCharges => 'مصاريف إضافية';

  @override
  String get stayHomeExtraChargesNote => 'تُخصم تلقائياً عند المغادرة';

  @override
  String get stayHomeNoActiveStayTitle => 'لا توجد إقامة حالية';

  @override
  String get stayHomeNoActiveStayBody =>
      'بمجرد تسجيل دخولك، ستظهر هنا غرفتك ورمز الدخول والخدمات.';

  @override
  String get extendStayTitle => 'تمديد الإقامة';

  @override
  String get extendStayNewCheckOutLabel => 'تاريخ المغادرة الجديد';

  @override
  String get extendStayNightsAddedLabel => 'عدد الليالي المضافة';

  @override
  String get extendStayCta => 'تأكيد التمديد';

  @override
  String get extendStaySuccessTitle => 'تم تمديد الإقامة';

  @override
  String extendStaySuccessBody(String date, String amount) {
    return 'تاريخ مغادرتك الآن $date. تمت إضافة $amount إلى فاتورتك.';
  }

  @override
  String get extendStayNotEligible =>
      'تمديد الإقامة متاح فقط أثناء إقامتك الحالية.';
}
