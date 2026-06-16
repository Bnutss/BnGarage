class AppStrings {
  static const _data = <String, Map<String, String>>{
    'ru': {
      // ── Onboarding ──────────────────────────────────────────────────────────
      'onb_welcome_title': 'Добро пожаловать',
      'onb_welcome_desc': 'BnGarage — личный гараж\nв вашем кармане',
      'onb_cars_title': 'Ваши автомобили',
      'onb_cars_desc':
          'Добавляйте авто, сохраняйте фото\nи всю важную информацию',
      'onb_service_title': 'История обслуживания',
      'onb_service_desc':
          'Фиксируйте каждую замену масла,\nфильтров и любых деталей',
      'onb_reminders_title': 'Умные напоминания',
      'onb_reminders_desc':
          'Не пропустите ТО — напоминания\nпо пробегу и по дате',
      'onb_setup_title': 'Настройка',
      'onb_lang_label': 'Язык интерфейса',
      'onb_theme_label': 'Тема оформления',
      'onb_theme_light': 'Светлая',
      'onb_theme_dark': 'Тёмная',
      'onb_next': 'Далее',
      'onb_skip': 'Пропустить',
      'onb_start': 'Начать',

      // ── Navigation ──────────────────────────────────────────────────────────
      'nav_cars': 'Авто',
      'nav_reminders': 'Напоминания',
      'nav_settings': 'Настройки',

      // ── Common ──────────────────────────────────────────────────────────────
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'error_prefix': 'Ошибка: ',
      'required_field': 'Обязательное поле',
      'enter_number': 'Введите число',
      'enter_amount': 'Введите сумму',
      'enter_0_100': 'Введите 0–100',
      'invalid_year': 'Некорректный год',
      'enter_number_short': 'Число',
      'not_specified': 'Не указана',
      'today': 'Сегодня',
      'km_suffix': 'км',
      'mo_suffix': 'мес.',

      // ── Photo ───────────────────────────────────────────────────────────────
      'photo_camera': 'Камера',
      'photo_gallery': 'Галерея',
      'photo_delete': 'Удалить фото',
      'photo_add_car': 'Добавить фото автомобиля',
      'photo_tap_to_select': 'Нажмите для выбора',

      // ── Cars list ───────────────────────────────────────────────────────────
      'cars_empty_title': 'Гараж пуст',
      'cars_empty_subtitle': 'Добавьте первый автомобиль',
      'cars_add_fab': 'Добавить авто',
      'status_overdue': 'Просрочено',
      'status_soon': 'Скоро',

      // ── Car detail ──────────────────────────────────────────────────────────
      'car_service_history': 'История обслуживания',
      'car_all_records': 'Все записи',
      'car_no_records': 'Записей нет',
      'car_add_record': 'Добавить',
      'car_delete_title': 'Удалить автомобиль?',
      'car_mileage_label': 'Пробег',
      'car_fuel_label': 'Топливо',
      'car_trans_label': 'КПП',
      'car_color_label': 'Цвет',
      'car_tint_label': 'Тонировка',
      'car_tint_has': 'Есть',
      'car_tint_date_label': 'Дата тонировки',

      // ── Add / Edit car ──────────────────────────────────────────────────────
      'add_car_title': 'Новый автомобиль',
      'edit_car_title': 'Редактировать',
      'car_basic_info': 'Основная информация',
      'car_tech_info': 'Технические данные',
      'car_tint_section': 'Тонировка',
      'car_brand': 'Марка *',
      'car_model': 'Модель *',
      'car_year': 'Год *',
      'car_mileage_field': 'Пробег *',
      'car_vin_optional': 'VIN (необязательно)',
      'car_color_optional': 'Цвет (необязательно)',
      'car_fuel_type': 'Тип топлива',
      'car_transmission': 'Коробка передач',
      'car_has_tint': 'Есть тонировка',
      'car_tint_percent': 'Процент тонировки',
      'car_tint_date': 'Дата тонировки',

      // ── Fuel types ──────────────────────────────────────────────────────────
      'fuel_gasoline': 'Бензин',
      'fuel_diesel': 'Дизель',
      'fuel_electric': 'Электро',
      'fuel_hybrid': 'Гибрид',
      'fuel_gas': 'Газ (Пропан/Метан)',

      // ── Transmission ────────────────────────────────────────────────────────
      'trans_automatic': 'Автомат',
      'trans_manual': 'Механика',

      // ── Category labels ─────────────────────────────────────────────────────
      'cat_oil': 'Масло',
      'cat_brakes': 'Тормоза',
      'cat_tires': 'Шины',
      'cat_suspension': 'Подвеска',
      'cat_transmission': 'Трансмиссия',
      'cat_engine': 'Двигатель',
      'cat_other': 'Другое',

      // ── Service list ────────────────────────────────────────────────────────
      'service_history': 'История обслуживания',
      'service_no_records': 'Записей нет',
      'service_add_first':
          'Нажмите + чтобы добавить первую\nзапись обслуживания',

      // ── Add record ──────────────────────────────────────────────────────────
      'add_record_title': 'Новая запись',
      'record_category': 'Категория',
      'record_basic_info': 'Основная информация',
      'record_name': 'Название *',
      'record_mileage_field': 'Пробег при замене (км) *',
      'record_date': 'Дата замены',
      'record_next_service': 'Следующая замена',
      'record_interval_hint':
          'Укажите интервал для автоматического напоминания',
      'record_interval_km': 'Через (км)',
      'record_interval_mo': 'Через (мес.)',
      'record_extra': 'Дополнительно',
      'record_cost': 'Стоимость',
      'record_note': 'Заметка',

      // ── Record detail ───────────────────────────────────────────────────────
      'detail_record_title': 'Детали записи',
      'detail_category': 'Категория',
      'detail_date': 'Дата замены',
      'detail_mileage_at': 'Пробег при замене',
      'detail_interval_km': 'Интервал (км)',
      'detail_interval_mo': 'Интервал (мес.)',
      'detail_cost': 'Стоимость',
      'detail_note': 'Заметка',
      'detail_next_service': 'Следующая замена',
      'detail_overdue': 'Замена просрочена',
      'detail_scheduled': 'Замена запланирована',
      'detail_by_mileage': 'По пробегу',
      'detail_by_date': 'По дате',
      'detail_photos': 'Фотографии',

      // ── Reminders ───────────────────────────────────────────────────────────
      'reminders_title': 'Напоминания',
      'reminders_overdue': 'Просрочено',
      'reminders_soon': 'Скоро',
      'reminders_ok': 'Всё в порядке',
      'reminders_empty':
          'Нет просроченных или предстоящих\nзамен и обслуживаний',
      'reminders_all_good': 'Всё в порядке!',

      // ── Settings ────────────────────────────────────────────────────────────
      'settings_title': 'Настройки',
      'settings_appear': 'Внешний вид',
      'settings_language': 'Язык',
      'settings_about': 'О приложении',
      'settings_theme': 'Тема',
      'settings_dark': 'Тёмная',
      'settings_light': 'Светлая',
      'settings_privacy': 'Политика конфиденциальности',
      'settings_version': 'Версия приложения',
      'settings_privacy_text':
          'Все данные об автомобилях и записях хранятся '
          'локально на вашем устройстве и не загружаются '
          'на внешние серверы.\n\n'
          'Приложение не собирает персональные данные '
          'и не требует регистрации.',
      'settings_got_it': 'Понятно',
      'settings_lang_ru': 'Рус',
      'settings_lang_en': 'Eng',
      'settings_lang_uz': 'O\'z',
    },

    'en': {
      // ── Onboarding ──────────────────────────────────────────────────────────
      'onb_welcome_title': 'Welcome',
      'onb_welcome_desc': 'BnGarage — your personal\ngarage in your pocket',
      'onb_cars_title': 'Your Cars',
      'onb_cars_desc': 'Add vehicles, save photos\nand all important details',
      'onb_service_title': 'Service History',
      'onb_service_desc': 'Log every oil change,\nfilter and parts replacement',
      'onb_reminders_title': 'Smart Reminders',
      'onb_reminders_desc':
          'Never miss a service — alerts\nby mileage and by date',
      'onb_setup_title': 'Setup',
      'onb_lang_label': 'Interface language',
      'onb_theme_label': 'App theme',
      'onb_theme_light': 'Light',
      'onb_theme_dark': 'Dark',
      'onb_next': 'Next',
      'onb_skip': 'Skip',
      'onb_start': 'Get Started',

      // ── Navigation ──────────────────────────────────────────────────────────
      'nav_cars': 'Cars',
      'nav_reminders': 'Reminders',
      'nav_settings': 'Settings',

      // ── Common ──────────────────────────────────────────────────────────────
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'error_prefix': 'Error: ',
      'required_field': 'Required field',
      'enter_number': 'Enter a number',
      'enter_amount': 'Enter an amount',
      'enter_0_100': 'Enter 0–100',
      'invalid_year': 'Invalid year',
      'enter_number_short': 'Number',
      'not_specified': 'Not specified',
      'today': 'Today',
      'km_suffix': 'km',
      'mo_suffix': 'mo.',

      // ── Photo ───────────────────────────────────────────────────────────────
      'photo_camera': 'Camera',
      'photo_gallery': 'Gallery',
      'photo_delete': 'Delete photo',
      'photo_add_car': 'Add car photo',
      'photo_tap_to_select': 'Tap to select',

      // ── Cars list ───────────────────────────────────────────────────────────
      'cars_empty_title': 'Garage is empty',
      'cars_empty_subtitle': 'Add your first car',
      'cars_add_fab': 'Add car',
      'status_overdue': 'Overdue',
      'status_soon': 'Due soon',

      // ── Car detail ──────────────────────────────────────────────────────────
      'car_service_history': 'Service History',
      'car_all_records': 'All records',
      'car_no_records': 'No records',
      'car_add_record': 'Add record',
      'car_delete_title': 'Delete car?',
      'car_mileage_label': 'Mileage',
      'car_fuel_label': 'Fuel',
      'car_trans_label': 'Trans.',
      'car_color_label': 'Color',
      'car_tint_label': 'Tint',
      'car_tint_has': 'Yes',
      'car_tint_date_label': 'Tint date',

      // ── Add / Edit car ──────────────────────────────────────────────────────
      'add_car_title': 'New Car',
      'edit_car_title': 'Edit',
      'car_basic_info': 'Basic Information',
      'car_tech_info': 'Technical Details',
      'car_tint_section': 'Tint',
      'car_brand': 'Make *',
      'car_model': 'Model *',
      'car_year': 'Year *',
      'car_mileage_field': 'Mileage *',
      'car_vin_optional': 'VIN (optional)',
      'car_color_optional': 'Color (optional)',
      'car_fuel_type': 'Fuel type',
      'car_transmission': 'Transmission',
      'car_has_tint': 'Has tint',
      'car_tint_percent': 'Tint percentage',
      'car_tint_date': 'Tint date',

      // ── Fuel types ──────────────────────────────────────────────────────────
      'fuel_gasoline': 'Gasoline',
      'fuel_diesel': 'Diesel',
      'fuel_electric': 'Electric',
      'fuel_hybrid': 'Hybrid',
      'fuel_gas': 'Gas (Propane/Methane)',

      // ── Transmission ────────────────────────────────────────────────────────
      'trans_automatic': 'Automatic',
      'trans_manual': 'Manual',

      // ── Category labels ─────────────────────────────────────────────────────
      'cat_oil': 'Oil',
      'cat_brakes': 'Brakes',
      'cat_tires': 'Tires',
      'cat_suspension': 'Suspension',
      'cat_transmission': 'Transmission',
      'cat_engine': 'Engine',
      'cat_other': 'Other',

      // ── Service list ────────────────────────────────────────────────────────
      'service_history': 'Service History',
      'service_no_records': 'No records',
      'service_add_first': 'Tap + to add your\nfirst service record',

      // ── Add record ──────────────────────────────────────────────────────────
      'add_record_title': 'New Record',
      'record_category': 'Category',
      'record_basic_info': 'Basic Information',
      'record_name': 'Title *',
      'record_mileage_field': 'Mileage at service (km) *',
      'record_date': 'Service date',
      'record_next_service': 'Next service',
      'record_interval_hint': 'Set interval for automatic reminder',
      'record_interval_km': 'After (km)',
      'record_interval_mo': 'After (mo.)',
      'record_extra': 'Additional',
      'record_cost': 'Cost',
      'record_note': 'Note',

      // ── Record detail ───────────────────────────────────────────────────────
      'detail_record_title': 'Record Details',
      'detail_category': 'Category',
      'detail_date': 'Service Date',
      'detail_mileage_at': 'Mileage at Service',
      'detail_interval_km': 'Interval (km)',
      'detail_interval_mo': 'Interval (mo.)',
      'detail_cost': 'Cost',
      'detail_note': 'Note',
      'detail_next_service': 'Next Service',
      'detail_overdue': 'Service Overdue',
      'detail_scheduled': 'Service Scheduled',
      'detail_by_mileage': 'By mileage',
      'detail_by_date': 'By date',
      'detail_photos': 'Photos',

      // ── Reminders ───────────────────────────────────────────────────────────
      'reminders_title': 'Reminders',
      'reminders_overdue': 'Overdue',
      'reminders_soon': 'Due soon',
      'reminders_ok': 'All good',
      'reminders_empty': 'No overdue or upcoming\nservice or maintenance',
      'reminders_all_good': 'All good!',

      // ── Settings ────────────────────────────────────────────────────────────
      'settings_title': 'Settings',
      'settings_appear': 'Appearance',
      'settings_language': 'Language',
      'settings_about': 'About',
      'settings_theme': 'Theme',
      'settings_dark': 'Dark',
      'settings_light': 'Light',
      'settings_privacy': 'Privacy Policy',
      'settings_version': 'App Version',
      'settings_privacy_text':
          'All car and service data is stored locally '
          'on your device and is never uploaded '
          'to external servers.\n\n'
          'The app does not collect personal data '
          'and does not require registration.',
      'settings_got_it': 'Got it',
      'settings_lang_ru': 'Rus',
      'settings_lang_en': 'Eng',
      'settings_lang_uz': 'O\'z',
    },

    'uz': {
      // ── Onboarding ──────────────────────────────────────────────────────────
      'onb_welcome_title': 'Xush kelibsiz',
      'onb_welcome_desc': 'BnGarage — shaxsiy garaj\nsizning cho\'ntakingizda',
      'onb_cars_title': 'Sizning avtomobillaringiz',
      'onb_cars_desc': 'Avtomobillar qo\'shing, rasmlarni\nsaqlang va barcha muhim ma\'lumotlarni',
      'onb_service_title': 'Xizmat tarixi',
      'onb_service_desc': 'Har bir moy almashtirish,\nfiltrlar va qismlar almashtirishni qayd eting',
      'onb_reminders_title': 'Aqlli eslatmalar',
      'onb_reminders_desc': 'Xizmatni o\'tkazib yubormang —\nyurish masofasi va sana bo\'yicha ogohlantirishlar',
      'onb_setup_title': 'Sozlash',
      'onb_lang_label': 'Interfeys tili',
      'onb_theme_label': 'Ilova mavzusi',
      'onb_theme_light': 'Yorug\'',
      'onb_theme_dark': 'Qorong\'u',
      'onb_next': 'Keyingi',
      'onb_skip': 'O\'tkazib yuborish',
      'onb_start': 'Boshlash',

      // ── Navigation ──────────────────────────────────────────────────────────
      'nav_cars': 'Avtomobillar',
      'nav_reminders': 'Eslatmalar',
      'nav_settings': 'Sozlamalar',

      // ── Common ──────────────────────────────────────────────────────────────
      'save': 'Saqlash',
      'cancel': 'Bekor qilish',
      'delete': 'O\'chirish',
      'error_prefix': 'Xato: ',
      'required_field': 'Majburiy maydon',
      'enter_number': 'Raqam kiriting',
      'enter_amount': 'Summani kiriting',
      'enter_0_100': '0–100 kiriting',
      'invalid_year': 'Noto\'g\'ri yil',
      'enter_number_short': 'Raqam',
      'not_specified': 'Ko\'rsatilmagan',
      'today': 'Bugun',
      'km_suffix': 'km',
      'mo_suffix': 'oy',

      // ── Photo ───────────────────────────────────────────────────────────────
      'photo_camera': 'Kamera',
      'photo_gallery': 'Galereya',
      'photo_delete': 'Rasmni o\'chirish',
      'photo_add_car': 'Avtomobil rasmini qo\'shish',
      'photo_tap_to_select': 'Tanlash uchun bosing',

      // ── Cars list ───────────────────────────────────────────────────────────
      'cars_empty_title': 'Garaj bo\'sh',
      'cars_empty_subtitle': 'Birinchi avtomobilni qo\'shing',
      'cars_add_fab': 'Avtomobil qo\'shish',
      'status_overdue': 'Muddati o\'tgan',
      'status_soon': 'Tez orada',

      // ── Car detail ──────────────────────────────────────────────────────────
      'car_service_history': 'Xizmat tarixi',
      'car_all_records': 'Barcha yozuvlar',
      'car_no_records': 'Yozuvlar yo\'q',
      'car_add_record': 'Qo\'shish',
      'car_delete_title': 'Avtomobilni o\'chirish?',
      'car_mileage_label': 'Yurish masofasi',
      'car_fuel_label': 'Yoqilg\'i',
      'car_trans_label': 'KPP',
      'car_color_label': 'Rang',
      'car_tint_label': 'Tonirovka',
      'car_tint_has': 'Bor',
      'car_tint_date_label': 'Tonirovka sanasi',

      // ── Add / Edit car ──────────────────────────────────────────────────────
      'add_car_title': 'Yangi avtomobil',
      'edit_car_title': 'Tahrirlash',
      'car_basic_info': 'Asosiy ma\'lumotlar',
      'car_tech_info': 'Texnik ma\'lumotlar',
      'car_tint_section': 'Tonirovka',
      'car_brand': 'Brend *',
      'car_model': 'Model *',
      'car_year': 'Yil *',
      'car_mileage_field': 'Yurish masofasi *',
      'car_vin_optional': 'VIN (ixtiyoriy)',
      'car_color_optional': 'Rang (ixtiyoriy)',
      'car_fuel_type': 'Yoqilg\'i turi',
      'car_transmission': 'Korobka uzatishi',
      'car_has_tint': 'Tonirovka bor',
      'car_tint_percent': 'Tonirovka foizi',
      'car_tint_date': 'Tonirovka sanasi',

      // ── Fuel types ──────────────────────────────────────────────────────────
      'fuel_gasoline': 'Benzin',
      'fuel_diesel': 'Dizel',
      'fuel_electric': 'Elektr',
      'fuel_hybrid': 'Gibrid',
      'fuel_gas': 'Gaz (Propan/Metan)',

      // ── Transmission ────────────────────────────────────────────────────────
      'trans_automatic': 'Avtomat',
      'trans_manual': 'Mexanika',

      // ── Category labels ─────────────────────────────────────────────────────
      'cat_oil': 'Moy',
      'cat_brakes': 'Tormozlar',
      'cat_tires': 'Shinalar',
      'cat_suspension': 'Podveska',
      'cat_transmission': 'Transmissiya',
      'cat_engine': 'Dvigatel',
      'cat_other': 'Boshqa',

      // ── Service list ────────────────────────────────────────────────────────
      'service_history': 'Xizmat tarixi',
      'service_no_records': 'Yozuvlar yo\'q',
      'service_add_first': 'Birinchi xizmat yozuvini\nqo\'shish uchun + bosing',

      // ── Add record ──────────────────────────────────────────────────────────
      'add_record_title': 'Yangi yozuv',
      'record_category': 'Kategoriya',
      'record_basic_info': 'Asosiy ma\'lumotlar',
      'record_name': 'Nomi *',
      'record_mileage_field': 'Xizmat paytida yurish masofasi (km) *',
      'record_date': 'Xizmat sanasi',
      'record_next_service': 'Keyingi xizmat',
      'record_interval_hint': 'Avtomatik eslatma uchun intervalni kiriting',
      'record_interval_km': 'Keyin (km)',
      'record_interval_mo': 'Keyin (oy)',
      'record_extra': 'Qo\'shimcha',
      'record_cost': 'Narx',
      'record_note': 'Eslatma',

      // ── Record detail ───────────────────────────────────────────────────────
      'detail_record_title': 'Yozuv tafsilotlari',
      'detail_category': 'Kategoriya',
      'detail_date': 'Xizmat sanasi',
      'detail_mileage_at': 'Xizmat paytida yurish masofasi',
      'detail_interval_km': 'Interval (km)',
      'detail_interval_mo': 'Interval (oy)',
      'detail_cost': 'Narx',
      'detail_note': 'Eslatma',
      'detail_next_service': 'Keyingi xizmat',
      'detail_overdue': 'Xizmat muddati o\'tgan',
      'detail_scheduled': 'Xizmat rejalashtirilgan',
      'detail_by_mileage': 'Yurish masofasi bo\'yicha',
      'detail_by_date': 'Sana bo\'yicha',
      'detail_photos': 'Rasmlar',

      // ── Reminders ───────────────────────────────────────────────────────────
      'reminders_title': 'Eslatmalar',
      'reminders_overdue': 'Muddati o\'tgan',
      'reminders_soon': 'Tez orada',
      'reminders_ok': 'Hammasi joyida',
      'reminders_empty': 'Muddati o\'tgan yoki kelgusi\nxizmatlar yo\'q',
      'reminders_all_good': 'Hammasi joyida!',

      // ── Settings ────────────────────────────────────────────────────────────
      'settings_title': 'Sozlamalar',
      'settings_appear': 'Ko\'rinish',
      'settings_language': 'Til',
      'settings_about': 'Ilova haqida',
      'settings_theme': 'Mavzu',
      'settings_dark': 'Qorong\'u',
      'settings_light': 'Yorug\'',
      'settings_privacy': 'Maxfiylik siyosati',
      'settings_version': 'Ilova versiyasi',
      'settings_privacy_text':
          'Barcha avtomobil va xizmat ma\'lumotlari\n'
          'qurilmangizda mahalliy saqlanadi va tashqi\n'
          'serverlarga yuklanmaydi.\n\n'
          'Ilova shaxsiy ma\'lumotlarni to\'playdi\n'
          'va ro\'yxatdan o\'tishni talab qilmaydi.',
      'settings_got_it': 'Tushundim',
      'settings_lang_ru': 'Rus',
      'settings_lang_en': 'Eng',
    },
  };

  static String get(String key, String langCode) =>
      _data[langCode]?[key] ?? _data['ru']![key] ?? key;
}
