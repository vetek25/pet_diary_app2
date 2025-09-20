import "package:flutter/widgets.dart";
import "package:intl/intl.dart";

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale("en"), Locale("ru"), Locale("uk")];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get localeName => locale.toLanguageTag();

  static final Map<String, Map<String, String>> _localizedValues = {
    "en": {
      "app.title": "PetCare Diary",
      "splash.tagline":
          "Caring for your pet every day.",
      "login.welcomeTitle": "Welcome to\nPetCare Diary",
      "login.welcomeDescription": "Caring for your pet every day.",
      "login.signIn": "Sign in to your account",
      "login.email": "Email",
      "login.emailHint": "petlover@mail.com",
      "login.password": "Password",
      "login.passwordHint": "********",
      "login.forgotPassword": "Forgot password?",
      "login.continue": "Continue",
      "login.or": "or",
      "login.continueGoogle": "Continue with Google",
      "login.continueApple": "Continue with Apple",
      "login.continueGuest": "Continue as guest",
      "dashboard.greeting": "Hi, {name}!",
      "dashboard.buddies": "Your buddies",
      "dashboard.quickActions": "Quick actions",
      "dashboard.upcomingReminders": "Upcoming reminders",
      "dashboard.noReminders":
          "No reminders yet. Add your first to stay on track!",
      "dashboard.noPetsYet": "Add your first pet to see it here.",
      "dashboard.addPetCta": "Add pet",
      "editPet.title": "Edit pet",
      "editPet.saveChanges": "Save changes",
      "editPet.deleteConfirmTitle": "Delete pet",
      "editPet.deleteConfirmBody":
          "Are you sure you want to remove this pet? This action can't be undone.",
      "editPet.deleteConfirmYes": "Delete",
      "dashboard.summary": "You have {pets} pets and {reminders} reminders",
      "quickAction.addDocument.title": "Add document",
      "quickAction.addDocument.subtitle": "Labs, vaccines, receipts",
      "quickAction.logClinicVisit.title": "Log clinic visit",
      "quickAction.logClinicVisit.subtitle": "Diagnosis, recommendations",
      "quickAction.createReminder.title": "Create reminder",
      "quickAction.createReminder.subtitle": "Medication or care routine",
      "quickAction.addPet.title": "Add new pet",
      "quickAction.addPet.subtitle": "Start a fresh profile",
      "common.cancel": "Cancel",
      "common.save": "Save",
      "common.create": "Create",
      "common.delete": "Delete",
      "common.close": "Close",
      "common.edit": "Edit",
      "documents.title": "Documents",
      "documents.addTooltip": "Add document",
      "documents.noPets": "Add a pet before uploading documents.",
      "documents.emptyState":
          "Upload examinations, lab results, or notes for this pet.",
      "documents.addFirst": "Upload document",
      "documents.petLabel": "Pet",
      "documents.supportedFormats.title": "Supported formats",
      "documents.supportedFormats.imagesHeader": "Images:",
      "documents.supportedFormats.imagesList": "JPG / JPEG, PNG, HEIC",
      "documents.supportedFormats.docsHeader": "Documents:",
      "documents.supportedFormats.docsList": "PDF, DOC / DOCX, XLS / XLSX, TXT",
      "documents.supportedFormats.notesHeader": "Text notes:",
      "documents.supportedFormats.notesList": "Create directly in the app",
      "documents.addFile": "Upload file",
      "documents.addNote": "Create note",
      "documents.fileNotAccessible": "Selected file is not accessible.",
      "documents.pickError": "Failed to add document: {error}",
      "documents.createNote": "New note",
      "documents.editNote": "Edit note",
      "documents.noteTitleLabel": "Note title",
      "documents.noteContentLabel": "Note text",
      "documents.noteValidationError": "Enter title and note text.",
      "documents.rename.title": "Rename document",
      "documents.rename.label": "Document name",
      "documents.delete.title": "Delete document",
      "documents.delete.question": "Delete \"{title}\" permanently?",
      "documents.action.rename": "Rename",
      "documents.action.editNote": "Edit note",
      "documents.action.delete": "Delete",
      "documents.webUnsupported":
          "Document storage is not available on web yet.",
      "documents.heroSubtitle":
          "Keep medical records, analyses, and notes tidy.",
      "documents.quickUpload": "Upload file",
      "documents.quickNote": "Write note",
      "documents.sectionLibrary": "Document library",
      "documents.emptyTitle": "No documents yet",
      "documents.emptySubtitle":
          "Upload prescriptions, lab results, or notes to keep everything in one place.",
      "documents.lastUpdated": "Last update {date}",
      "petCard.age": "Age",
      "petCard.weight": "Weight",
      "petCard.chip": "Chip",
      "petProfile.title": "Pet profile",
      "petProfile.overview": "Overview",
      "petProfile.notes": "Notes",
      "petProfile.reminders": "Reminders",
      "petProfile.timeline": "Timeline",
      "petProfile.birthDate": "Birth date",
      "petProfile.gender": "Gender",
      "petProfile.microchip": "Microchip",
      "petProfile.weightTrend": "Weight dynamics",
      "petProfile.weightLatest": "Latest: {weight} kg • {date}",
      "petProfile.addWeight": "Add weight",
      "petProfile.weightEmpty": "No weight measurements yet. Add the first entry.",
      "petProfile.weightField": "Weight (kg)",
      "petProfile.weightDate": "Date: {date}",
      "petProfile.weightValidation": "Enter a valid weight value.",
      "petProfile.noPetSelected": "No pet selected",
      "addPet.title": "Add new pet",
      "addPet.nameLabel": "Name",
      "addPet.nameRequired": "Name is required",
      "addPet.speciesLabel": "Species",
      "addPet.speciesRequired": "Species is required",
      "addPet.breedLabel": "Breed",
      "addPet.genderLabel": "Gender",
      "addPet.birthDateLabel": "Birth date",
      "addPet.birthDateHelp": "Select birth date",
      "addPet.weightLabel": "Weight, kg",
      "addPet.weightHint": "e.g. 4.2",
      "addPet.weightRequired": "Please enter weight",
      "addPet.microchipLabel": "Microchip",
      "addPet.notesLabel": "Notes",
      "addPet.tagsLabel": "Tags",
      "addPet.colorLabel": "Card color",
      "addPet.cancel": "Cancel",
      "addPet.save": "Save",
      "addPet.limitReached": "Upgrade to add more pets in your diary.",
      "tag.indoor": "Indoor",
      "tag.allergyCare": "Allergy care",
      "tag.microchip": "Microchip",
      "tag.active": "Active",
      "tag.noAllergies": "No allergies",
      "note.luna": "Sensitive to chicken-based food.",
      "note.milo": "Prefers evening walks.",
      "reminder.title.vaccineBooster": "Vaccine booster",
      "reminder.title.weightCheck": "Weight check",
      "reminder.title.monthlyGrooming": "Monthly grooming",
      "reminder.date.tomorrow0930": "Tomorrow - 09:30",
      "reminder.date.mar28": "Mar 28 - 16:00",
      "reminder.date.apr03": "Apr 03 - 11:00",
      "reminder.noPetsYet": "Add a pet to start scheduling reminders.",
      "reminder.addTitle": "New reminder",
      "reminder.editTitle": "Edit reminder",
      "reminder.petLabel": "Pet",
      "reminder.titleLabel": "Reminder title",
      "reminder.titleHint": "Annual check-up",
      "reminder.titleRequired": "Title is required",
      "reminder.typeLabel": "Type",
      "reminder.dateLabel": "Date & time",
      "reminder.notesLabel": "Notes",
      "reminder.notesHint": "Optional note",
      "reminder.save": "Save reminder",
      "reminder.delete": "Delete",
      "reminder.repeatToggle": "Repeat",
      "reminder.repeatIntervalLabel": "Repeat interval",
      "reminder.repeatCountLabel": "Number of repeats",
      "reminder.repeatCountHint": "e.g. 10",
      "reminder.repeatCountRequired": "Enter repeat count",
      "reminder.repeatSummary": "Every {interval} · {count}",
      "reminder.interval.once": "Once",
      "reminder.interval.12h": "Every 12 hours",
      "reminder.interval.daily": "Daily",
      "reminder.interval.weekly": "Weekly",
      "reminder.interval.monthly": "Monthly",
      "reminder.interval.quarterly": "Every 3 months",
      "reminder.interval.yearly": "Yearly",
      "reminder.type.checkup": "Check-up",
      "reminder.type.vaccination": "Vaccination",
      "reminder.type.medication": "Medication",
      "reminder.type.grooming": "Grooming",
      "reminder.type.care": "Care",
      "notification.settingsTitle": "Notification settings",
      "notification.masterToggle": "Enable notifications",
      "notification.masterToggleSubtitle":
          "Turn all push notifications on or off.",
      "notification.silentMode": "Silent mode",
      "notification.silentModeSubtitle": "Mute notification sounds.",
      "notification.duplicateEmail": "Duplicate to email",
      "notification.duplicateEmailSubtitle":
          "Send copies of notifications to the owner email.",
      "notification.channelsTitle": "Channels",
      "notification.channelReminders": "Personal reminders",
      "notification.channelRemindersSubtitle":
          "Medication courses and manual reminders.",
      "notification.channelClinic": "Clinic alerts",
      "notification.channelClinicSubtitle":
          "Upcoming visits, lab results, and doctor messages.",
      "notification.channelBilling": "Subscription updates",
      "notification.channelBillingSubtitle":
          "Renewal reminders and billing notices.",
      "notification.settingsHint":
          "Adjust channels to decide which notifications stay active.\nSilent mode disables sounds but keeps alerts visible.",
      "reminder.noPetsYet": "Add a pet to start scheduling reminders.",
      "reminder.addTitle": "New reminder",
      "reminder.editTitle": "Edit reminder",
      "reminder.petLabel": "Pet",
      "reminder.titleLabel": "Reminder title",
      "reminder.titleHint": "Annual check-up",
      "reminder.titleRequired": "Title is required",
      "reminder.typeLabel": "Type",
      "reminder.dateLabel": "Date & time",
      "reminder.notesLabel": "Notes",
      "reminder.notesHint": "Optional note",
      "reminder.save": "Save reminder",
      "reminder.delete": "Delete",
      "reminder.type.checkup": "Check-up",
      "reminder.type.vaccination": "Vaccination",
      "reminder.type.medication": "Medication",
      "reminder.type.grooming": "Grooming",
      "reminder.type.care": "Care",
      "notification.settingsTitle": "Notification settings",
      "notification.masterToggle": "Enable notifications",
      "notification.masterToggleSubtitle":
          "Turn all push notifications on or off.",
      "notification.silentMode": "Silent mode",
      "notification.silentModeSubtitle": "Mute notification sounds.",
      "notification.duplicateEmail": "Duplicate to email",
      "notification.duplicateEmailSubtitle":
          "Send copies of notifications to the owner email.",
      "notification.channelsTitle": "Channels",
      "notification.channelReminders": "Personal reminders",
      "notification.channelRemindersSubtitle":
          "Medication courses and manual reminders.",
      "notification.channelClinic": "Clinic alerts",
      "notification.channelClinicSubtitle":
          "Upcoming visits, lab results, and doctor messages.",
      "notification.channelBilling": "Subscription updates",
      "notification.channelBillingSubtitle":
          "Renewal reminders and billing notices.",
      "notification.settingsHint":
          "Adjust channels to decide which notifications stay active.\nSilent mode disables sounds but keeps alerts visible.",
      "gender.female": "Female",
      "gender.male": "Male",
      "age.underOneMonth": "Under 1 mo",
      "unit.kg": "kg",
      "nextEvent.clinic": "Next visit",
      "nextEvent.grooming": "Grooming",
      "timeline.wellness.title": "Wellness check",
      "timeline.wellness.description":
          "Routine examination, all vitals are stable.",
      "timeline.bloodTest.title": "Blood test",
      "timeline.bloodTest.description":
          "Results uploaded by clinic. No issues detected.",
      "timeline.upcoming.description": "Scheduled upcoming visit for {name}.",
      "timeline.upcoming.date": "Upcoming",
    },
    "ru": {
      "app.title": "PetCare Diary",
      "splash.tagline":
          "Забота о питомце каждый день.",
      "login.welcomeTitle": "Добро пожаловать\nв PetCare Diary",
      "login.welcomeDescription": "Забота о питомце каждый день.",
      "login.signIn": "Войдите в аккаунт",
      "login.email": "Email",
      "login.emailHint": "petlover@mail.com",
      "login.password": "Пароль",
      "login.passwordHint": "••••••••",
      "login.forgotPassword": "Забыли пароль?",
      "login.continue": "Продолжить",
      "login.or": "или",
      "login.continueGoogle": "Войти через Google",
      "login.continueApple": "Войти через Apple",
      "login.continueGuest": "Продолжить как гость",
      "dashboard.greeting": "Привет, {name}!",
      "dashboard.buddies": "Ваши питомцы",
      "dashboard.quickActions": "Быстрые действия",
      "dashboard.upcomingReminders": "Ближайшие напоминания",
      "dashboard.noReminders":
          "Напоминаний пока нет. Добавьте первое, чтобы ничего не забыть!",
      "dashboard.noPetsYet":
          "Добавьте первого питомца, чтобы увидеть его карточку.",
      "dashboard.addPetCta": "Добавить питомца",
      "dashboard.summary": "У вас {pets} питомцев и {reminders} напоминаний",
      "quickAction.addDocument.title": "Добавить документ",
      "quickAction.addDocument.subtitle": "Анализы, прививки, чеки",
      "quickAction.logClinicVisit.title": "Записать визит",
      "quickAction.logClinicVisit.subtitle": "Диагнозы, рекомендации",
      "quickAction.createReminder.title": "Создать напоминание",
      "quickAction.createReminder.subtitle": "Лечение или уход",
      "quickAction.addPet.title": "Добавить питомца",
      "quickAction.addPet.subtitle": "Начать новую карточку",
      "common.cancel": "Отмена",
      "common.save": "Сохранить",
      "common.create": "Создать",
      "common.delete": "Удалить",
      "common.close": "Закрыть",
      "common.edit": "Редактировать",
      "documents.title": "Документы",
      "documents.addTooltip": "Добавить документ",
      "documents.noPets": "Добавьте питомца, чтобы загружать документы.",
      "documents.emptyState":
          "Загрузите анализы, заключения или заметки для этого питомца.",
      "documents.addFirst": "Загрузить документ",
      "documents.petLabel": "Питомец",
      "documents.supportedFormats.title": "Поддерживаемые форматы",
      "documents.supportedFormats.imagesHeader": "Изображения:",
      "documents.supportedFormats.imagesList": "JPG / JPEG, PNG, HEIC",
      "documents.supportedFormats.docsHeader": "Документы:",
      "documents.supportedFormats.docsList": "PDF, DOC / DOCX, XLS / XLSX, TXT",
      "documents.supportedFormats.notesHeader": "Текстовые заметки:",
      "documents.supportedFormats.notesList": "Создаются прямо в приложении",
      "documents.addFile": "Загрузить файл",
      "documents.addNote": "Создать заметку",
      "documents.fileNotAccessible":
          "Не удалось получить доступ к выбранному файлу.",
      "documents.pickError": "Не удалось добавить документ: {error}",
      "documents.createNote": "Новая заметка",
      "documents.editNote": "Редактировать заметку",
      "documents.noteTitleLabel": "Название",
      "documents.noteContentLabel": "Текст заметки",
      "documents.noteValidationError": "Введите название и текст заметки.",
      "documents.rename.title": "Переименовать документ",
      "documents.rename.label": "Название документа",
      "documents.delete.title": "Удалить документ",
      "documents.delete.question": "Удалить «{title}» навсегда?",
      "documents.action.rename": "Переименовать",
      "documents.action.editNote": "Редактировать заметку",
      "documents.action.delete": "Удалить",
      "documents.webUnsupported":
          "Хранилище документов недоступно в веб-версии.",
      "documents.heroSubtitle":
          "Храните анализы, назначения и заметки в одном месте.",
      "documents.quickUpload": "Загрузить файл",
      "documents.quickNote": "Создать заметку",
      "documents.sectionLibrary": "Библиотека документов",
      "documents.emptyTitle": "Пока нет документов",
      "documents.emptySubtitle":
          "Добавьте выписки, анализы или фото рецептов, чтобы ничего не потерялось.",
      "documents.lastUpdated": "Последнее обновление {date}",
      "petCard.age": "Возраст",
      "petCard.weight": "Вес",
      "petCard.chip": "Чип",
      "petProfile.title": "Профиль питомца",
      "petProfile.overview": "Общее",
      "petProfile.notes": "Заметки",
      "petProfile.reminders": "Напоминания",
      "petProfile.timeline": "История",
      "petProfile.birthDate": "Дата рождения",
      "petProfile.gender": "Пол",
      "petProfile.microchip": "Микрочип",
      "petProfile.weightTrend": "Динамика веса",
      "petProfile.weightLatest": "Последнее: {weight} кг • {date}",
      "petProfile.addWeight": "Добавить вес",
      "petProfile.weightEmpty": "Запишите первое значение веса, чтобы увидеть график.",
      "petProfile.weightField": "Вес (кг)",
      "petProfile.weightDate": "Дата: {date}",
      "petProfile.weightValidation": "Введите корректное значение веса.",
      "petProfile.noPetSelected": "Питомец не выбран",
      "addPet.title": "Новый питомец",
      "addPet.nameLabel": "Имя",
      "addPet.nameRequired": "Введите имя",
      "addPet.speciesLabel": "Вид",
      "addPet.speciesRequired": "Укажите вид",
      "addPet.breedLabel": "Порода",
      "addPet.genderLabel": "Пол",
      "addPet.birthDateLabel": "Дата рождения",
      "addPet.birthDateHelp": "Выберите дату",
      "addPet.weightLabel": "Вес, кг",
      "addPet.weightHint": "например 4.2",
      "addPet.weightRequired": "Введите вес",
      "addPet.microchipLabel": "Микрочип",
      "addPet.notesLabel": "Заметки",
      "addPet.tagsLabel": "Теги",
      "addPet.colorLabel": "Цвет карточки",
      "addPet.cancel": "Отмена",
      "addPet.save": "Сохранить",
      "addPet.limitReached": "Обновите тариф, чтобы добавить больше питомцев.",
      "tag.indoor": "Домашний",
      "tag.allergyCare": "Уход при аллергии",
      "tag.microchip": "С чипом",
      "tag.active": "Активный",
      "tag.noAllergies": "Без аллергий",
      "note.luna": "Чувствительна к корму с курицей.",
      "note.milo": "Предпочитает вечерние прогулки.",
      "reminder.title.vaccineBooster": "Вакцина",
      "reminder.title.weightCheck": "Контроль веса",
      "reminder.title.monthlyGrooming": "Ежемесячный груминг",
      "reminder.date.tomorrow0930": "Завтра - 09:30",
      "reminder.date.mar28": "28 мар - 16:00",
      "reminder.date.apr03": "3 апр - 11:00",
      "reminder.noPetsYet": "Добавьте питомца, чтобы создавать напоминания.",
      "reminder.addTitle": "Новое напоминание",
      "reminder.editTitle": "Редактировать напоминание",
      "reminder.petLabel": "Питомец",
      "reminder.titleLabel": "Название напоминания",
      "reminder.titleHint": "Плановый осмотр",
      "reminder.titleRequired": "Введите название",
      "reminder.typeLabel": "Тип",
      "reminder.dateLabel": "Дата и время",
      "reminder.notesLabel": "Заметки",
      "reminder.notesHint": "Дополнительная информация",
      "reminder.save": "Сохранить напоминание",
      "reminder.delete": "Удалить",
      "reminder.repeatToggle": "Повторять",
      "reminder.repeatIntervalLabel": "Интервал повторения",
      "reminder.repeatCountLabel": "Количество повторов",
      "reminder.repeatCountHint": "например 10",
      "reminder.repeatCountRequired": "Укажите количество повторов",
      "reminder.repeatSummary": "{interval} · {count}",
      "reminder.interval.once": "Один раз",
      "reminder.interval.12h": "Каждые 12 часов",
      "reminder.interval.daily": "Каждый день",
      "reminder.interval.weekly": "Каждую неделю",
      "reminder.interval.monthly": "Каждый месяц",
      "reminder.interval.quarterly": "Каждые 3 месяца",
      "reminder.interval.yearly": "Каждый год",
      "reminder.type.checkup": "Осмотр",
      "reminder.type.vaccination": "Вакцинация",
      "reminder.type.medication": "Лекарства",
      "reminder.type.grooming": "Груминг",
      "reminder.type.care": "Уход",
      "notification.settingsTitle": "Настройки уведомлений",
      "notification.masterToggle": "Включить уведомления",
      "notification.masterToggleSubtitle": "Переключает все push-уведомления.",
      "notification.silentMode": "Беззвучный режим",
      "notification.silentModeSubtitle": "Отключить звук у уведомлений.",
      "notification.duplicateEmail": "Дублировать на e-mail",
      "notification.duplicateEmailSubtitle":
          "Отправлять копии уведомлений на почту владельца.",
      "notification.channelsTitle": "Каналы",
      "notification.channelReminders": "Личные напоминания",
      "notification.channelRemindersSubtitle":
          "Курсы лекарств и созданные вручную напоминания.",
      "notification.channelClinic": "Уведомления от клиник",
      "notification.channelClinicSubtitle":
          "Будущие визиты, результаты анализов и сообщения врача.",
      "notification.channelBilling": "Подписка",
      "notification.channelBillingSubtitle":
          "Напоминания о продлении и платежах.",
      "notification.settingsHint":
          "Настройте каналы, чтобы оставить только нужные уведомления.\nБеззвучный режим отключает звук, но сохраняет всплывающие подсказки.",
      "reminder.noPetsYet": "Добавьте питомца, чтобы создавать напоминания.",
      "reminder.addTitle": "Новое напоминание",
      "reminder.editTitle": "Редактировать напоминание",
      "reminder.petLabel": "Питомец",
      "reminder.titleLabel": "Название напоминания",
      "reminder.titleHint": "Плановый осмотр",
      "reminder.titleRequired": "Введите название",
      "reminder.typeLabel": "Тип",
      "reminder.dateLabel": "Дата и время",
      "reminder.notesLabel": "Заметки",
      "reminder.notesHint": "Дополнительная информация",
      "reminder.save": "Сохранить напоминание",
      "reminder.delete": "Удалить",
      "reminder.type.checkup": "Осмотр",
      "reminder.type.vaccination": "Вакцинация",
      "reminder.type.medication": "Лекарства",
      "reminder.type.grooming": "Груминг",
      "reminder.type.care": "Уход",
      "notification.settingsTitle": "Настройки уведомлений",
      "notification.masterToggle": "Включить уведомления",
      "notification.masterToggleSubtitle": "Переключает все push-уведомления.",
      "notification.silentMode": "Беззвучный режим",
      "notification.silentModeSubtitle": "Отключить звук у уведомлений.",
      "notification.duplicateEmail": "Дублировать на e-mail",
      "notification.duplicateEmailSubtitle":
          "Отправлять копии уведомлений на почту владельца.",
      "notification.channelsTitle": "Каналы",
      "notification.channelReminders": "Личные напоминания",
      "notification.channelRemindersSubtitle":
          "Курсы лекарств и созданные вручную напоминания.",
      "notification.channelClinic": "Уведомления от клиник",
      "notification.channelClinicSubtitle":
          "Будущие визиты, результаты анализов и сообщения врача.",
      "notification.channelBilling": "Подписка",
      "notification.channelBillingSubtitle":
          "Напоминания о продлении и платежах.",
      "notification.settingsHint":
          "Настройте каналы, чтобы оставить только нужные уведомления.\nБеззвучный режим отключает звук, но сохраняет всплывающие подсказки.",
      "gender.female": "Самка",
      "gender.male": "Самец",
      "age.underOneMonth": "Младше месяца",
      "unit.kg": "кг",
      "nextEvent.clinic": "Следующий визит",
      "nextEvent.grooming": "Груминг",
      "timeline.wellness.title": "Профилактический осмотр",
      "timeline.wellness.description": "Плановый осмотр, показатели в норме.",
      "timeline.bloodTest.title": "Анализ крови",
      "timeline.bloodTest.description":
          "Клиника загрузила результаты. Отклонений нет.",
      "timeline.upcoming.description":
          "Запланирован предстоящий визит для {name}.",
      "timeline.upcoming.date": "Скоро",
    },
    "uk": {
      "app.title": "PetCare Diary",
      "splash.tagline":
          "Піклування про улюбленця щодня.",
      "login.welcomeTitle": "Ласкаво просимо\nдо PetCare Diary",
      "login.welcomeDescription": "Піклування про улюбленця щодня.",
      "login.signIn": "Увійдіть до акаунта",
      "login.email": "Email",
      "login.emailHint": "petlover@mail.com",
      "login.password": "Пароль",
      "login.passwordHint": "••••••••",
      "login.forgotPassword": "Забули пароль?",
      "login.continue": "Продовжити",
      "login.or": "або",
      "login.continueGoogle": "Увійти через Google",
      "login.continueApple": "Увійти через Apple",
      "login.continueGuest": "Продовжити як гість",
      "dashboard.greeting": "Привіт, {name}!",
      "dashboard.buddies": "Ваші улюбленці",
      "dashboard.quickActions": "Швидкі дії",
      "dashboard.upcomingReminders": "Найближчі нагадування",
      "dashboard.noReminders":
          "Поки що нагадувань немає. Додайте перше, щоб нічого не забути!",
      "dashboard.noPetsYet":
          "Додайте першого улюбленця, щоб побачити його картку.",
      "dashboard.addPetCta": "Додати улюбленця",
      "dashboard.summary": "У вас {pets} улюбленців та {reminders} нагадувань",
      "quickAction.addDocument.title": "Додати документ",
      "quickAction.addDocument.subtitle": "Аналізи, щеплення, чеки",
      "quickAction.logClinicVisit.title": "Записати візит",
      "quickAction.logClinicVisit.subtitle": "Діагнози, рекомендації",
      "quickAction.createReminder.title": "Створити нагадування",
      "quickAction.createReminder.subtitle": "Лікування або догляд",
      "quickAction.addPet.title": "Додати улюбленця",
      "quickAction.addPet.subtitle": "Почати нову картку",
      "common.cancel": "Скасувати",
      "common.save": "Зберегти",
      "common.create": "Створити",
      "common.delete": "Видалити",
      "common.close": "Закрити",
      "common.edit": "Редагувати",
      "documents.title": "Документи",
      "documents.addTooltip": "Додати документ",
      "documents.noPets": "Додайте улюбленця, щоб завантажувати документи.",
      "documents.emptyState":
          "Завантажуйте аналізи, висновки або нотатки для цього улюбленця.",
      "documents.addFirst": "Завантажити документ",
      "documents.petLabel": "Улюбленець",
      "documents.supportedFormats.title": "Підтримувані формати",
      "documents.supportedFormats.imagesHeader": "Зображення:",
      "documents.supportedFormats.imagesList": "JPG / JPEG, PNG, HEIC",
      "documents.supportedFormats.docsHeader": "Документи:",
      "documents.supportedFormats.docsList": "PDF, DOC / DOCX, XLS / XLSX, TXT",
      "documents.supportedFormats.notesHeader": "Текстові нотатки:",
      "documents.supportedFormats.notesList": "Створюються прямо в застосунку",
      "documents.addFile": "Завантажити файл",
      "documents.addNote": "Створити нотатку",
      "documents.fileNotAccessible":
          "Не вдалося отримати доступ до вибраного файла.",
      "documents.pickError": "Не вдалося додати документ: {error}",
      "documents.createNote": "Нова нотатка",
      "documents.editNote": "Редагувати нотатку",
      "documents.noteTitleLabel": "Назва",
      "documents.noteContentLabel": "Текст нотатки",
      "documents.noteValidationError": "Вкажіть назву та текст нотатки.",
      "documents.rename.title": "Перейменувати документ",
      "documents.rename.label": "Назва документа",
      "documents.delete.title": "Видалити документ",
      "documents.delete.question": "Видалити «{title}» назавжди?",
      "documents.action.rename": "Перейменувати",
      "documents.action.editNote": "Редагувати нотатку",
      "documents.action.delete": "Видалити",
      "documents.webUnsupported": "Сховище документів недоступне у веб-версії.",
      "documents.heroSubtitle":
          "Зберігайте аналізи, призначення та нотатки в одному місці.",
      "documents.quickUpload": "Завантажити файл",
      "documents.quickNote": "Створити нотатку",
      "documents.sectionLibrary": "Бібліотека документів",
      "documents.emptyTitle": "Документів ще немає",
      "documents.emptySubtitle":
          "Додайте виписки, аналізи чи фото рецептів, щоб нічого не загубилося.",
      "documents.lastUpdated": "Останнє оновлення {date}",
      "petCard.age": "Вік",
      "petCard.weight": "Вага",
      "petCard.chip": "Чип",
      "petProfile.title": "Профіль улюбленця",
      "petProfile.overview": "Загальне",
      "petProfile.notes": "Нотатки",
      "petProfile.reminders": "Нагадування",
      "petProfile.timeline": "Історія",
      "petProfile.birthDate": "Дата народження",
      "petProfile.gender": "Стать",
      "petProfile.microchip": "Мікрочип",
      "petProfile.weightTrend": "Динаміка ваги",
      "petProfile.weightLatest": "Останній показник: {weight} кг • {date}",
      "petProfile.addWeight": "Додати вагу",
      "petProfile.weightEmpty": "Додайте перше значення ваги, щоб побачити графік.",
      "petProfile.weightField": "Вага (кг)",
      "petProfile.weightDate": "Дата: {date}",
      "petProfile.weightValidation": "Вкажіть коректне значення ваги.",
      "petProfile.noPetSelected": "Улюбленця не обрано",
      "addPet.title": "Новий улюбленець",
      "addPet.nameLabel": "Ім'я",
      "addPet.nameRequired": "Вкажіть ім'я",
      "addPet.speciesLabel": "Вид",
      "addPet.speciesRequired": "Вкажіть вид",
      "addPet.breedLabel": "Порода",
      "addPet.genderLabel": "Стать",
      "addPet.birthDateLabel": "Дата народження",
      "addPet.birthDateHelp": "Оберіть дату",
      "addPet.weightLabel": "Вага, кг",
      "addPet.weightHint": "наприклад 4.2",
      "addPet.weightRequired": "Вкажіть вагу",
      "addPet.microchipLabel": "Мікрочип",
      "addPet.notesLabel": "Нотатки",
      "addPet.tagsLabel": "Теги",
      "addPet.colorLabel": "Колір картки",
      "addPet.cancel": "Скасувати",
      "addPet.save": "Зберегти",
      "addPet.limitReached": "Оновіть тариф, щоб додати більше улюбленців.",
      "tag.indoor": "Домашній",
      "tag.allergyCare": "Догляд при алергії",
      "tag.microchip": "З чипом",
      "tag.active": "Активний",
      "tag.noAllergies": "Без алергій",
      "note.luna": "Чутлива до корму з куркою.",
      "note.milo": "Полюбляє вечірні прогулянки.",
      "reminder.title.vaccineBooster": "Вакцина",
      "reminder.title.weightCheck": "Контроль ваги",
      "reminder.title.monthlyGrooming": "Щомісячний грумінг",
      "reminder.date.tomorrow0930": "Завтра - 09:30",
      "reminder.date.mar28": "28 бер - 16:00",
      "reminder.date.apр03": "3 кві - 11:00",
      "reminder.noPetsYet": "Додайте улюбленця, щоб створювати нагадування.",
      "reminder.addTitle": "Нове нагадування",
      "reminder.editTitle": "Редагувати нагадування",
      "reminder.petLabel": "Улюбленець",
      "reminder.titleLabel": "Назва нагадування",
      "reminder.titleHint": "Плановий огляд",
      "reminder.titleRequired": "Вкажіть назву",
      "reminder.typeLabel": "Тип",
      "reminder.dateLabel": "Дата й час",
      "reminder.notesLabel": "Нотатки",
      "reminder.notesHint": "Додаткова інформація",
      "reminder.save": "Зберегти нагадування",
      "reminder.delete": "Видалити",
      "reminder.repeatToggle": "Повторювати",
      "reminder.repeatIntervalLabel": "Інтервал повторення",
      "reminder.repeatCountLabel": "Кількість повторів",
      "reminder.repeatCountHint": "наприклад 10",
      "reminder.repeatCountRequired": "Вкажіть кількість повторів",
      "reminder.repeatSummary": "{interval} · {count}",
      "reminder.interval.once": "Один раз",
      "reminder.interval.12h": "Кожні 12 годин",
      "reminder.interval.daily": "Щодня",
      "reminder.interval.weekly": "Щотижня",
      "reminder.interval.monthly": "Щомісяця",
      "reminder.interval.quarterly": "Кожні 3 місяці",
      "reminder.interval.yearly": "Щороку",
      "reminder.type.checkup": "Огляд",
      "reminder.type.vaccination": "Вакцинація",
      "reminder.type.medication": "Ліки",
      "reminder.type.grooming": "Грумінг",
      "reminder.type.care": "Догляд",
      "notification.settingsTitle": "Налаштування сповіщень",
      "notification.masterToggle": "Увімкнути сповіщення",
      "notification.masterToggleSubtitle":
          "Загальний перемикач push-сповіщень.",
      "notification.silentMode": "Беззвучний режим",
      "notification.silentModeSubtitle": "Вимкнути звук сповіщень.",
      "notification.duplicateEmail": "Дублювати на e-mail",
      "notification.duplicateEmailSubtitle":
          "Надсилати копії сповіщень на пошту власника.",
      "notification.channelsTitle": "Канали",
      "notification.channelReminders": "Особисті нагадування",
      "notification.channelRemindersSubtitle":
          "Курси ліків та створені вручну нагадування.",
      "notification.channelClinic": "Сповіщення від клінік",
      "notification.channelClinicSubtitle":
          "Майбутні візити, результати аналізів та повідомлення лікаря.",
      "notification.channelBilling": "Підписка",
      "notification.channelBillingSubtitle":
          "Нагадування про продовження та платежі.",
      "notification.settingsHint":
          "Налаштуйте канали, щоб залишити лише потрібні сповіщення.\nБеззвучний режим вимикає звук, але залишає повідомлення видимими.",
      "reminder.noPetsYet": "Додайте улюбленця, щоб створювати нагадування.",
      "reminder.addTitle": "Нове нагадування",
      "reminder.editTitle": "Редагувати нагадування",
      "reminder.petLabel": "Улюбленець",
      "reminder.titleLabel": "Назва нагадування",
      "reminder.titleHint": "Плановий огляд",
      "reminder.titleRequired": "Вкажіть назву",
      "reminder.typeLabel": "Тип",
      "reminder.dateLabel": "Дата й час",
      "reminder.notesLabel": "Нотатки",
      "reminder.notesHint": "Додаткова інформація",
      "reminder.save": "Зберегти нагадування",
      "reminder.delete": "Видалити",
      "reminder.type.checkup": "Огляд",
      "reminder.type.vaccination": "Вакцинація",
      "reminder.type.medication": "Ліки",
      "reminder.type.grooming": "Грумінг",
      "reminder.type.care": "Догляд",
      "notification.settingsTitle": "Налаштування сповіщень",
      "notification.masterToggle": "Увімкнути сповіщення",
      "notification.masterToggleSubtitle":
          "Загальний перемикач push-сповіщень.",
      "notification.silentMode": "Беззвучний режим",
      "notification.silentModeSubtitle": "Вимкнути звук сповіщень.",
      "notification.duplicateEmail": "Дублювати на e-mail",
      "notification.duplicateEmailSubtitle":
          "Надсилати копії сповіщень на пошту власника.",
      "notification.channelsTitle": "Канали",
      "notification.channelReminders": "Особисті нагадування",
      "notification.channelRemindersSubtitle":
          "Курси ліків та створені вручну нагадування.",
      "notification.channelClinic": "Сповіщення від клінік",
      "notification.channelClinicSubtitle":
          "Майбутні візити, результати аналізів та повідомлення лікаря.",
      "notification.channelBilling": "Підписка",
      "notification.channelBillingSubtitle":
          "Нагадування про продовження та платежі.",
      "notification.settingsHint":
          "Налаштуйте канали, щоб залишити лише потрібні сповіщення.\nБеззвучний режим вимикає звук, але залишає повідомлення видимими.",
      "gender.female": "Самка",
      "gender.male": "Самець",
      "age.underOneMonth": "Менше місяця",
      "unit.kg": "кг",
      "nextEvent.clinic": "Наступний візит",
      "nextEvent.grooming": "Грумінг",
      "timeline.wellness.title": "Профілактичний огляд",
      "timeline.wellness.description": "Плановий огляд, показники в нормі.",
      "timeline.bloodTest.title": "Аналіз крові",
      "timeline.bloodTest.description":
          "Клініка завантажила результати. Відхилень немає.",
      "timeline.upcoming.description":
          "Заплановано майбутній візит для {name}.",
      "timeline.upcoming.date": "Незабаром",
    },
  };

  String _translate(String key) {
    final languageCode = _localizedValues.containsKey(locale.languageCode)
        ? locale.languageCode
        : "en";
    final languageMap = _localizedValues[languageCode]!;
    return languageMap[key] ?? _localizedValues["en"]![key] ?? key;
  }

  String get appTitle => _translate("app.title");
  String get splashTagline => _translate("splash.tagline");
  String get reminderNoPetsYet => _translate("reminder.noPetsYet");
  String get addReminderTitle => _translate("reminder.addTitle");
  String get editReminderTitle => _translate("reminder.editTitle");
  String get reminderPetLabel => _translate("reminder.petLabel");
  String get reminderTitleLabel => _translate("reminder.titleLabel");
  String get reminderTitleHint => _translate("reminder.titleHint");
  String get reminderTitleRequired => _translate("reminder.titleRequired");
  String get reminderTypeLabel => _translate("reminder.typeLabel");
  String get reminderDateLabel => _translate("reminder.dateLabel");
  String get reminderNotesLabel => _translate("reminder.notesLabel");
  String get reminderNotesHint => _translate("reminder.notesHint");
  String get reminderRepeatToggle => _translate("reminder.repeatToggle");
  String get reminderRepeatIntervalLabel =>
      _translate("reminder.repeatIntervalLabel");
  String get reminderRepeatCountLabel =>
      _translate("reminder.repeatCountLabel");
  String get reminderRepeatCountHint => _translate("reminder.repeatCountHint");
  String get reminderRepeatCountRequired =>
      _translate("reminder.repeatCountRequired");
  String get saveReminder => _translate("reminder.save");
  String get deleteReminder => _translate("reminder.delete");
  String reminderIntervalName(String key) =>
      _translate("reminder.interval.$key");
  String get reminderRepeatSummaryTemplate =>
      _translate("reminder.repeatSummary");
  String reminderRepeatCount(int count) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          count,
          one: "${count} раз",
          few: "${count} раза",
          many: "${count} раз",
          other: "${count} раз",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          count,
          one: "${count} раз",
          few: "${count} рази",
          many: "${count} разів",
          other: "${count} разів",
          locale: localeName,
        );
      default:
        return Intl.plural(
          count,
          one: "${count} time",
          other: "${count} times",
          locale: localeName,
        );
    }
  }

  String reminderType(String key) => _translate("reminder.type.$key");
  String formatReminderDate(DateTime date) =>
      DateFormat.yMMMEd(localeName).format(date);
  String get notificationSettingsTitle =>
      _translate("notification.settingsTitle");
  String get notificationMasterToggle =>
      _translate("notification.masterToggle");
  String get notificationMasterToggleSubtitle =>
      _translate("notification.masterToggleSubtitle");
  String get notificationSilentMode => _translate("notification.silentMode");
  String get notificationSilentModeSubtitle =>
      _translate("notification.silentModeSubtitle");
  String get notificationDuplicateEmail =>
      _translate("notification.duplicateEmail");
  String get notificationDuplicateEmailSubtitle =>
      _translate("notification.duplicateEmailSubtitle");
  String get notificationChannelsTitle =>
      _translate("notification.channelsTitle");
  String get notificationChannelReminders =>
      _translate("notification.channelReminders");
  String get notificationChannelRemindersSubtitle =>
      _translate("notification.channelRemindersSubtitle");
  String get notificationChannelClinic =>
      _translate("notification.channelClinic");
  String get notificationChannelClinicSubtitle =>
      _translate("notification.channelClinicSubtitle");
  String get notificationChannelBilling =>
      _translate("notification.channelBilling");
  String get notificationChannelBillingSubtitle =>
      _translate("notification.channelBillingSubtitle");
  String get notificationSettingsHint =>
      _translate("notification.settingsHint");
  String formatReminderTime(DateTime date) =>
      DateFormat.Hm(localeName).format(date);

  String get loginWelcomeTitle => _translate("login.welcomeTitle");
  String get loginWelcomeDescription => _translate("login.welcomeDescription");
  String get loginSignIn => _translate("login.signIn");
  String get loginEmailLabel => _translate("login.email");
  String get loginEmailHint => _translate("login.emailHint");
  String get loginPasswordLabel => _translate("login.password");
  String get loginPasswordHint => _translate("login.passwordHint");
  String get loginForgotPassword => _translate("login.forgotPassword");
  String get loginContinue => _translate("login.continue");
  String get loginOr => _translate("login.or");
  String get loginContinueWithGoogle => _translate("login.continueGoogle");
  String get loginContinueWithApple => _translate("login.continueApple");
  String get loginContinueAsGuest => _translate("login.continueGuest");

  String greeting(String name) {
    return _translate("dashboard.greeting").replaceFirst("{name}", name);
  }

  String get dashboardBuddies => _translate("dashboard.buddies");
  String get dashboardQuickActions => _translate("dashboard.quickActions");
  String get dashboardUpcomingReminders =>
      _translate("dashboard.upcomingReminders");
  String get dashboardNoReminders => _translate("dashboard.noReminders");
  String get dashboardNoPetsYet => _translate("dashboard.noPetsYet");
  String get dashboardAddPetCta => _translate("dashboard.addPetCta");
  String get editPetTitle => _translate("editPet.title");
  String get saveChanges => _translate("editPet.saveChanges");
  String get deletePetConfirmTitle => _translate("editPet.deleteConfirmTitle");
  String get deletePetConfirmBody => _translate("editPet.deleteConfirmBody");
  String get deletePetConfirmYes => _translate("editPet.deleteConfirmYes");

  String dashboardSummary(int petsCount, int remindersCount) {
    return _translate("dashboard.summary")
        .replaceFirst("{pets}", petsCount.toString())
        .replaceFirst("{reminders}", remindersCount.toString());
  }

  String quickActionTitle(String key) => _translate("quickAction.$key.title");
  String quickActionSubtitle(String key) =>
      _translate("quickAction.$key.subtitle");

  String get actionCancel => _translate("common.cancel");
  String get actionSave => _translate("common.save");
  String get actionCreate => _translate("common.create");
  String get actionDelete => _translate("common.delete");
  String get actionClose => _translate("common.close");
  String get actionEdit => _translate("common.edit");

  String get documentsTitle => _translate("documents.title");
  String get documentsAddTooltip => _translate("documents.addTooltip");
  String get documentsNoPets => _translate("documents.noPets");
  String get documentsEmptyState => _translate("documents.emptyState");
  String get documentsAddFirst => _translate("documents.addFirst");
  String get documentsPetLabel => _translate("documents.petLabel");
  String get documentsSupportedFormatsTitle =>
      _translate("documents.supportedFormats.title");
  String get documentsSupportedImagesHeader =>
      _translate("documents.supportedFormats.imagesHeader");
  String get documentsSupportedImagesList =>
      _translate("documents.supportedFormats.imagesList");
  String get documentsSupportedDocsHeader =>
      _translate("documents.supportedFormats.docsHeader");
  String get documentsSupportedDocsList =>
      _translate("documents.supportedFormats.docsList");
  String get documentsSupportedNotesHeader =>
      _translate("documents.supportedFormats.notesHeader");
  String get documentsSupportedNotesList =>
      _translate("documents.supportedFormats.notesList");
  String get documentsHeroSubtitle => _translate("documents.heroSubtitle");
  String get documentsQuickUpload => _translate("documents.quickUpload");
  String get documentsQuickNote => _translate("documents.quickNote");
  String get documentsLibraryTitle => _translate("documents.sectionLibrary");
  String get documentsEmptyTitle => _translate("documents.emptyTitle");
  String get documentsEmptySubtitle => _translate("documents.emptySubtitle");
  String documentsLastUpdatedLabel(DateTime date) {
    final formatted = DateFormat.yMMMEd(localeName).add_Hm().format(date);
    return _translate(
      "documents.lastUpdated",
    ).replaceFirst("{date}", formatted);
  }

  String documentsStatDocuments(int count) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          count,
          one: "$count документ",
          few: "$count документа",
          many: "$count документов",
          other: "$count документа",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          count,
          one: "$count документ",
          few: "$count документи",
          many: "$count документів",
          other: "$count документів",
          locale: localeName,
        );
      default:
        return Intl.plural(
          count,
          one: "$count document",
          other: "$count documents",
          locale: localeName,
        );
    }
  }

  String documentsStatImages(int count) {
    switch (locale.languageCode) {
      case "ru":
        return "$count фото";
      case "uk":
        return "$count фото";
      default:
        return Intl.plural(
          count,
          one: "$count photo",
          other: "$count photos",
          locale: localeName,
        );
    }
  }

  String documentsStatFiles(int count) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          count,
          one: "$count файл",
          few: "$count файла",
          many: "$count файлов",
          other: "$count файла",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          count,
          one: "$count файл",
          few: "$count файли",
          many: "$count файлів",
          other: "$count файлів",
          locale: localeName,
        );
      default:
        return Intl.plural(
          count,
          one: "$count file",
          other: "$count files",
          locale: localeName,
        );
    }
  }

  String documentsStatNotes(int count) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          count,
          one: "$count заметка",
          few: "$count заметки",
          many: "$count заметок",
          other: "$count заметки",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          count,
          one: "$count нотатка",
          few: "$count нотатки",
          many: "$count нотаток",
          other: "$count нотаток",
          locale: localeName,
        );
      default:
        return Intl.plural(
          count,
          one: "$count note",
          other: "$count notes",
          locale: localeName,
        );
    }
  }

  String get documentsAddFile => _translate("documents.addFile");
  String get documentsAddNote => _translate("documents.addNote");
  String get documentsFileNotAccessible =>
      _translate("documents.fileNotAccessible");
  String documentsPickError(Object error) => _translate(
    "documents.pickError",
  ).replaceFirst("{error}", error.toString());
  String get documentsCreateNote => _translate("documents.createNote");
  String get documentsEditNote => _translate("documents.editNote");
  String get documentsNoteTitleLabel => _translate("documents.noteTitleLabel");
  String get documentsNoteContentLabel =>
      _translate("documents.noteContentLabel");
  String get documentsNoteValidationError =>
      _translate("documents.noteValidationError");
  String get documentsRenameTitle => _translate("documents.rename.title");
  String get documentsRenameLabel => _translate("documents.rename.label");
  String get documentsDeleteTitle => _translate("documents.delete.title");
  String documentsDeleteQuestion(String title) =>
      _translate("documents.delete.question").replaceFirst("{title}", title);
  String get documentsActionRename => _translate("documents.action.rename");
  String get documentsActionEditNote => _translate("documents.action.editNote");
  String get documentsActionDelete => _translate("documents.action.delete");
  String get documentsWebUnsupported => _translate("documents.webUnsupported");

  String get petCardAge => _translate("petCard.age");
  String get petCardWeight => _translate("petCard.weight");
  String get petCardChip => _translate("petCard.chip");

  String get petProfileTitle => _translate("petProfile.title");
  String get petProfileOverview => _translate("petProfile.overview");
  String get petProfileNotes => _translate("petProfile.notes");
  String get petProfileReminders => _translate("petProfile.reminders");
  String get petProfileTimeline => _translate("petProfile.timeline");
  String get petProfileBirthDate => _translate("petProfile.birthDate");
  String get petProfileGender => _translate("petProfile.gender");
  String get petProfileMicrochip => _translate("petProfile.microchip");
  String get petProfileWeightTrend => _translate("petProfile.weightTrend");
  String petProfileWeightLatest(String weight, String date) => _translate("petProfile.weightLatest")
      .replaceFirst("{weight}", weight)
      .replaceFirst("{date}", date);
  String get petProfileAddWeight => _translate("petProfile.addWeight");
  String get petProfileWeightEmpty => _translate("petProfile.weightEmpty");
  String get petProfileWeightField => _translate("petProfile.weightField");
  String petProfileWeightDate(String date) =>
      _translate("petProfile.weightDate").replaceFirst("{date}", date);
  String get petProfileWeightValidation => _translate("petProfile.weightValidation");
  String get petProfileNoPetSelected => _translate("petProfile.noPetSelected");

  String get addPetTitle => _translate("addPet.title");
  String get addPetNameLabel => _translate("addPet.nameLabel");
  String get addPetNameRequired => _translate("addPet.nameRequired");
  String get addPetSpeciesLabel => _translate("addPet.speciesLabel");
  String get addPetSpeciesRequired => _translate("addPet.speciesRequired");
  String get addPetBreedLabel => _translate("addPet.breedLabel");
  String get addPetGenderLabel => _translate("addPet.genderLabel");
  String get addPetBirthDateLabel => _translate("addPet.birthDateLabel");
  String get addPetBirthDateHelp => _translate("addPet.birthDateHelp");
  String get addPetWeightLabel => _translate("addPet.weightLabel");
  String get addPetWeightHint => _translate("addPet.weightHint");
  String get addPetWeightRequired => _translate("addPet.weightRequired");
  String get addPetMicrochipLabel => _translate("addPet.microchipLabel");
  String get addPetNotesLabel => _translate("addPet.notesLabel");
  String get addPetTagsLabel => _translate("addPet.tagsLabel");
  String get addPetColorLabel => _translate("addPet.colorLabel");
  String get addPetCancel => _translate("addPet.cancel");
  String get addPetSave => _translate("addPet.save");
  String get addPetLimitReached => _translate("addPet.limitReached");

  String tagLabel(String key) => _translate("tag.$key");
  String? note(String key) =>
      _localizedValues.values.any((map) => map.containsKey("note.$key"))
      ? _translate("note.$key")
      : null;
  String genderLabel(String key) => _translate("gender.$key");

  String get ageUnderOneMonth => _translate("age.underOneMonth");
  String get unitKilograms => _translate("unit.kg");

  String nextEventLabel(String key, DateTime date) {
    final prefix = _translate("nextEvent.$key");
    final formattedDate = DateFormat.MMMd(localeName).format(date);
    return "$prefix - $formattedDate";
  }

  String timelineTitle(String key) => _translate("timeline.$key.title");
  String timelineDescription(String key, {String? name}) {
    final value = _translate("timeline.$key.description");
    if (name != null) {
      return value.replaceFirst("{name}", name);
    }
    return value;
  }

  String get timelineUpcomingDateLabel => _translate("timeline.upcoming.date");

  String formatFullDate(DateTime date) {
    return DateFormat.yMMMMd(localeName).format(date);
  }

  String ageYearsLabel(int years) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          years,
          one: "$years год",
          few: "$years года",
          many: "$years лет",
          other: "$years лет",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          years,
          one: "$years рік",
          few: "$years роки",
          many: "$years років",
          other: "$years років",
          locale: localeName,
        );
      default:
        return "$years yr${years == 1 ? "" : "s"}";
    }
  }

  String ageMonthsLabel(int months) {
    switch (locale.languageCode) {
      case "ru":
        return Intl.plural(
          months,
          one: "$months месяц",
          few: "$months месяца",
          many: "$months месяцев",
          other: "$months месяцев",
          locale: localeName,
        );
      case "uk":
        return Intl.plural(
          months,
          one: "$months місяць",
          few: "$months місяці",
          many: "$months місяців",
          other: "$months місяців",
          locale: localeName,
        );
      default:
        return "$months mo";
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.toLanguageTag();
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
