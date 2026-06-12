<div align="center">

# BnGarage

**Личный гараж в вашем кармане**

Учёт автомобилей · История обслуживания · Умные напоминания

</div>

---

## О приложении

BnGarage — мобильное приложение для автовладельцев, которое помогает держать под контролем всё, что связано с обслуживанием автомобиля. Все данные хранятся локально на устройстве — никаких серверов и регистраций.

## Функционал

| | Возможность | Описание |
|---|------------|----------|
| <img src="https://img.shields.io/badge/-Cars-185FA5?style=flat-square" /> | **Автомобили** | Добавление, редактирование, удаление машин с фотографиями и полной информацией |
| <img src="https://img.shields.io/badge/-Service-F59E0B?style=flat-square" /> | **Обслуживание** | Фиксация каждой замены: масло, тормоза, шины, подвеска, трансмиссия, двигатель |
| <img src="https://img.shields.io/badge/-Reminders-10B981?style=flat-square" /> | **Напоминания** | Автоматические уведомления по пробегу и по дате следующей замены |
| <img src="https://img.shields.io/badge/-Tint-8B5CF6?style=flat-square" /> | **Тонировка** | Отслеживание наличия, процента и даты тонировки |
| <img src="https://img.shields.io/badge/-Theme-EF4444?style=flat-square" /> | **Темы** | Тёмная и светлая тема с glassmorphism эффектами |
| <img src="https://img.shields.io/badge/-i18n-06B6D4?style=flat-square" /> | **Язык** | Русский и английский интерфейс |

## Стек технологий

```
Flutter 3.x · Material 3
├── State      → Riverpod
├── Navigation → GoRouter
├── Database   → sqflite (SQLite)
├── UI         → Glassmorphism · AnimatedContainer · BackdropFilter
├── Photos     → image_picker · cached_network_image
├── i18n       → intl + кастомный механизм локализации
└── Settings   → shared_preferences
```

## Структура проекта

```
lib/
├── core/
│   ├── constants/      Категории сервиса, типы топлива
│   ├── database/       SQLite helper (v2, миграции)
│   ├── l10n/           Локализация (ru, en)
│   ├── providers/      Theme, Locale, SharedPreferences
│   ├── router/         GoRouter с вложенными маршрутами
│   ├── theme/          Material 3 темы
│   ├── utils/          Пробег, фото, даты
│   └── widgets/        GlassNavBar, общие компоненты
├── features/
│   ├── cars/           CRUD автомобилей
│   ├── service_records/ Записи обслуживания
│   ├── reminders/      Умные напоминания
│   ├── onboarding/     Splash + онбординг
│   ├── settings/       Настройки темы и языка
│   ├── profile/        Профиль (в разработке)
│   └── auth/           Авторизация (в разработке)
└── main.dart
```

## Быстрый старт

```bash
# 1. Клонировать репозиторий
git clone https://github.com/your-username/BnGarage.git
cd BnGarage

# 2. Установить зависимости
flutter pub get

# 3. Сгенерировать код (riverpod_generator, freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Запустить
flutter run
```

## Навигация

```
/splash                              Заставка
/onboarding                          Язык → Слайды → Тема

/cars                                Список авто (карусель)
  /cars/add                          Добавление
  /cars/:carId                       Детали
    /cars/:carId/edit                Редактирование
    /cars/:carId/records             История обслуживания
      /cars/:carId/records/add       Новая запись
      /cars/:carId/records/:recId    Детали записи

/reminders                           Умные напоминания
/settings                            Настройки
```

## Категории обслуживания

| Категория | Иконка | Примеры |
|-----------|--------|---------|
| Масло | `opacity` | Замена масла, масляного фильтра |
| Тормоза | `disc_full` | Колодки, диски, жидкость |
| Шины | `tire_repair` | Сезонная замена, ротация |
| Подвеска | `car_repair` | Амортизаторы, рычаги, стойки |
| Трансмиссия | `settings` | ATF, сцепление |
| Двигатель | `engineering` | Свечи, ремни, ГРМ |
| Другое | `build` | Фильтр воздуха, антифриз |

## Дизайн

- **Glassmorphism** — нижняя навигация с `BackdropFilter` и размытием
- **Gradient AppBar** — от тёмного к синему (`#070C14 → #0D1B2E → #185FA5`)
- **Анимации** — `FadeTransition`, `SlideTransition`, `AnimatedContainer` для плавных переходов
- **Статусные бейджи** — пульсирующие индикаторы просроченных и предстоящих замен
- **Карусель авто** — `PageView` с gradient-карточками и генерацией цвета по бренду

---

<div align="center">

**Лицензия:** MIT

</div>
