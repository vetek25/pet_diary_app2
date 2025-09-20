# Pet Diary App – Development Log

## 1. Overview
- Flutter application targeting mobile/desktop/web for managing pet health records.
- Multi-language support (English, Russian, Ukrainian) handled via custom localization map.
- Data persistence through Hive for pets (`pet_diary`) and reminders (`pet_diary_reminders`).
- Provider pattern provides repositories across the widget tree. Splash screen ensures repositories finish initializing before showing UI.

## 2. Directory Structure (key folders)
- `lib/`
  - `l10n/` – `app_localizations.dart` with localization map, helpers for formatting/pluralization.
  - `models/` – `pet.dart`, `reminder.dart` domain models.
  - `services/` – `pet_repository.dart`, `reminder_repository.dart` (Hive persistence, business logic).
  - `screens/`
    - `splash_screen.dart` – splash + gate (awaits repo init, shows illustration).
    - `login_screen.dart` – authentication placeholder UI.
    - `dashboard_screen.dart` – home view with pet carousel, quick actions, upcoming reminders, FAB.
    - `add_pet_screen.dart` – add/edit pet form with delete handling.
    - `pet_card_screen.dart` – detailed pet profile, reminders section, timeline.
    - `reminder_form_sheet.dart` – modal bottom sheet for reminder creation/editing.
  - `widgets/` – reusable UI pieces (`pet_card.dart`).
  - `main.dart` – entrypoint configuring providers, theme, routes, splash gate.
- `test/` – `widget_test.dart` verifying localization/UI wiring using temp Hive stores.

## 3. Application Flow & Key Logic
### 3.1 Startup
1. `main()` ensures Flutter binding, calls `Hive.initFlutter()`, instantiates repositories, runs `PetDiaryApp`.
2. `PetDiaryApp` wraps `MaterialApp` in `MultiProvider` (pet & reminder repositories). Theme uses `ColorScheme.fromSeed` with modern pastel palette.
3. `MaterialApp.home` → `SplashGate`.
4. `SplashGate` (stateful) triggers `petRepository.init()` and `reminderRepository.init()` once. After both complete, waits 3 seconds, then shows `LoginScreen`.

### 3.2 Localization
- `AppLocalizations` contains `_localizedValues` per language.
- Exposes getters (`reminderRepeatToggle`, `reminderIntervalName`, `reminderRepeatCount`, etc.) for UI text & special formatting.
- `formatReminderDate`, `formatReminderTime` using `Intl` to respect locale.

### 3.3 Data Model & Persistence
#### Pet (`lib/models/pet.dart`)
- Fields: id, name, species, breed, gender, birthDate, weight, microchip, accentColor, tagKeys, optional avatar/notes/nextEvent fields.
- `fromStorage`/`toStorage` convert to Hive store.
- Helpers: `weightLabel`, `ageLabel`, `genderLabel`, `formattedBirthDate`, `note()`, `nextEventLabel()`, `microchipSuffix`.

#### Reminder (`lib/models/reminder.dart`)
- Fields: id, petId, title, type, dateTime, optional notes; recurrence flags (`isRepeating`, `repeatInterval`, `repeatCount`).
- Methods: `occurrenceAt`, `nextOccurrence`, `_addMonths` for monthly/quarterly logic; `recurrenceSummary` builds human-readable text using localization.

#### PetRepository (`lib/services/pet_repository.dart`)
- Hive box `pet_diary`. Methods: `init`, `_ensureInitialized`, `findPetById`, `savePet` (upsert), `addPet` proxy, `removePet`, `_seedPets` (demo cat data), `_save`, `dispose`.
- `isFreePlan` placeholder gating (limit 1 pet).

#### ReminderRepository (`lib/services/reminder_repository.dart`)
- Hive box `pet_diary_reminders`. Methods: `init`, `_ensureInitialized`, `remindersForPet` (sorted by next occurrence), `upcomingReminders` (returns `ReminderOccurrence` with next date), `upsert`, `delete`, `deleteForPet`, `_seedReminders` (demo one-time + repeating), `_save`, `dispose`.

### 3.4 UI Screens
#### SplashScreen (`lib/screens/splash_screen.dart`)
- Visual composition: gradients, stylized dog/cat, surrounding icons (food bowl, medication, syringe, calendar, medical services icon).
- Shows progress indicator + tagline.
- After 3 sec & repo init, replaced by login.

#### LoginScreen
- Pastel layout with decorated hero card, fields for email/password (no backend yet), options for social login & guest.

#### DashboardScreen
- Reads repositories via Provider.
- Quick actions list: add document (placeholder), log visit (placeholder), create reminder (opens `ReminderFormSheet`), add pet.
- Pet carousel using `PetCard` widget; fallback text when no pets.
- Upcoming reminders: uses `ReminderRepository.upcomingReminders`, shows next occurrence date/time, summary for repeating schedules, includes pet name.
- FAB opens add-pet flow.

#### AddPetScreen
- Stateful form using TextFormFields. Supports editing existing pet (`petId` argument) and deletion (confirms, removes reminders for pet).
- Fields: name, species, breed, gender dropdown, date picker, weight, microchip, notes, tag chips, accent color chips.

#### ReminderFormSheet
- Modal bottom sheet with `DraggableScrollableSheet`.
- Inputs: pet selector, title, type dropdown, repeat switch (interval dropdown, count input with validation), date/time pickers, notes.
- Saves via `ReminderRepository.upsert`. Delete button visible when editing.

#### PetCardScreen
- Accepts pet ID or full Pet. Watches repositories for live updates.
- Sections: overview, notes, reminders (list builder with recurrence summary, menu to edit/delete), timeline (static demo events + upcoming next event).
- Edit button pushes `AddPetScreen` for modifications.

### 3.5 Widgets
- `PetCard` displays gradient card with stats, tags, next event chip.
- `_FloatingItem`, `_DogFigure`, `_CatFigure` in splash for decorative elements.

### 3.6 Testing
- `test/widget_test.dart` sets up temp Hive directories, initializes repositories, pumps `PetDiaryApp`, asserts login UI text.

## 4. Notable Code Paths
- `main.dart`: App entry, provider setup, routing to splash.
- `SplashGate._initialize`: orchestrates repository init + artificial delay.
- `DashboardScreen._openAddPet` / quick actions: gating free plan, navigation.
- `ReminderRepository.upcomingReminders` vs `remindersForPet`: ensures repeating reminders surface with next occurrence.
- `ReminderFormSheet` validation: ensures repeat count > 0, handles `isRepeating` flag.
- `PetCardScreen`: obtains reminders via repo, shows next occurrence, uses popup menu for inline edit/delete.

## 5. Data Flow Summary
1. User launches app → splash while Hive boxes open, delay 3 sec.
2. Login screen (no auth yet) → `DashboardScreen` via navigation (Login screen button routes to dashboard).
3. Dashboard reads pets/reminders from repositories. Quick actions create new reminders/pets.
4. Add/edit pet updates repository (and reminders cleanup on delete).
5. Reminder form updates repository; `ReminderRepository` notifies listeners so dashboard & pet screens refresh automatically.
6. Pet profile shows full details with synced reminders list and timeline.

## 6. Remaining TODO / Future Work Considerations
- Build document storage and attachments for pets (photos, PDFs, medical records).
- Add shared access/invitations for family members and partner clinics.
- Expand the timeline into a fully categorized activity feed.
- Finish quick-action flows (visit log, document upload, extended reminder actions).
- Ship reliable push/local notifications with background scheduling.
- Implement authentication and subscription gating.
- Refresh the UI (dark theme, responsive layout tweaks).
- Harden automated tests and repository coverage.

## 7. Notifications & Reminder Enhancements
- Added `NotificationSettingsRepository` to persist notification preferences (enable/disable, silent mode, email duplication, channel toggles) via Hive.
- Implemented `NotificationService` that watches repositories and settings, computes upcoming occurrences for reminders (including recurrence intervals) and prepares schedules for future push integration.
- Extended `Reminder` model with recurrence metadata (`isRepeating`, `repeatInterval`, `repeatCount`) and helper methods (`occurrenceAt`, `nextOccurrence`, `recurrenceSummary`). Added sample repeating reminder in seed data.
- Built `ReminderFormSheet` UI for managing recurrence: toggle repeat, choose interval (12h/daily/weekly/monthly/quarterly/yearly), specify repeat count, validated inputs.
- Updated `DashboardScreen` to show upcoming reminders with recurrence summaries, expose quick action opening the reminder form, and added navigation to the new notification settings screen.
- Updated `PetCardScreen` reminders list to display next occurrence, recurrence summary, and popup menu for edit/delete, ensuring reminders sync with repository/service.
- Introduced `NotificationSettingsScreen` allowing user to configure notification toggles and channels.
- Splash gate now initializes pet, reminder, and notification settings repositories along with the notification service before unveiling login.
- Localizations expanded for all new strings (recurrence, notification settings, channel descriptions) in English, Russian, and Ukrainian.

## 2025-09-20 – Auth groundwork without breaking guest mode
- Kept the legacy guest-only flow intact: login button still navigates directly to the dashboard, profile editing remains local-only for unauthenticated users.
- Added but disabled new backend wiring (ApiClient, AuthRepository, SyncService, register/verify screens) so future email auth work has a foundation.
- Hooked login UI buttons back up (Create an account, Continue as guest), cleaned profile/avatar editing to show proper guest restrictions and avoid crashes.
- Deferred actual API calls and removed provider dependencies for now; backend integration planned as next step.
