# Frontend Multi-Livestock Support Implementation Plan

**Version:** 2.0  
**Date:** 2025-11-30  
**Purpose:** Update Flutter app to support multiple livestock types (Cattle, Pigs, Goats, Sheep, etc.) based on backend changes

---

## 📋 Overview

This plan outlines all frontend changes needed to support multiple livestock types, specifically:
- Replace `CalvingModel` with `BirthEventModel` (supporting both calving and farrowing)
- Add support for pig-specific events (aborted pregnancy)
- Make UI species-aware (dynamic labels based on livestock type)
- Update API integration to use new endpoints
- Update local database schema
- **IMPORTANT:** Backend tables have been renamed: `calving_types` → `birth_types`, `calving_problems` → `birth_problems`

---

## 🎯 Goals

1. ✅ Replace `CalvingModel` with generic `BirthEventModel`
2. ✅ Support both "calving" (cattle) and "farrowing" (pigs) in same model
3. ✅ Add `AbortedPregnancyModel` and form
4. ✅ Make UI labels species-aware (Parity/Lactation vs Parity/Litter, etc.)
5. ✅ Update stages to filter by livestock type
6. ✅ Update API calls to new endpoints (`birth-types`, `birth-problems` instead of `calving-types`, `calving-problems`)
7. ✅ Update local database schema with new column names (`birthTypeId`, `birthProblemsId`)

---

## 📦 Phase 1: Model Updates

### 1.1 Rename/Update CalvingModel to BirthEventModel
**File:** `lib/features/events/domain/model/birth_event_model.dart` (rename from `calving_model.dart`)

**Changes:**
- Rename class from `CalvingModel` to `BirthEventModel`
- Add `eventType` field (String: 'calving' or 'farrowing')
- **RENAME FIELDS:** `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- Add helper methods:
  ```dart
  String getEventName() => eventType == 'farrowing' ? 'Farrowing' : 'Calving';
  String getOffspringName() => eventType == 'farrowing' ? 'Piglet' : 'Calf';
  ```
- Update all field names to match backend (camelCase)

**Fields:**
```dart
final int? id;
final String uuid;
final String farmUuid;
final String livestockUuid;
final String eventType; // NEW: 'calving' or 'farrowing'
final String startDate;
final String? endDate;
final int birthTypeId; // RENAMED from calvingTypeId
final int? birthProblemsId; // RENAMED from calvingProblemsId
final int? reproductiveProblemId;
final String? remarks;
final String status;
final bool synced;
final String syncAction;
final String createdAt;
final String updatedAt;
```

---

### 1.2 Create AbortedPregnancyModel
**File:** `lib/features/events/domain/model/aborted_pregnancy_model.dart` (NEW)

**Fields:**
```dart
final int? id;
final String uuid;
final String farmUuid;
final String livestockUuid;
final String abortionDate;
final int? reproductiveProblemId;
final String? remarks;
final String status;
final bool synced;
final String syncAction;
final String createdAt;
final String updatedAt;
```

---

### 1.3 Create BirthTypeModel and BirthProblemModel
**File:** `lib/features/reference_data/domain/model/birth_type_model.dart` (NEW)
**File:** `lib/features/reference_data/domain/model/birth_problem_model.dart` (NEW)

**Note:** These replace `CalvingTypeModel` and `CalvingProblemModel` (or update existing models to use new table names)

**BirthTypeModel:**
```dart
final int id;
final String name;
final int? livestockTypeId; // null = generic, applies to all types
```

**BirthProblemModel:**
```dart
final int id;
final String name;
final int? livestockTypeId; // null = generic, applies to all types
```

---

### 1.4 Update EventLogTypes
**File:** `lib/features/events/domain/constants/event_log_types.dart`

**Changes:**
- Add `farrowing` constant
- Add `abortedPregnancy` constant
- Add helper method:
  ```dart
  static String getBirthEventType(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? farrowing : calving;
  }
  ```

---

## 📦 Phase 2: Database Schema Updates

### 2.1 Update Calving Table to Birth Events Table
**File:** `lib/features/events/data/tables/birth_event_table.dart` (rename from `calving_table.dart`)

**Changes:**
- Rename table from `calvings` to `birth_events`
- Add `eventType` column (TEXT)
- **RENAME COLUMNS:** `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- Update all column names to match backend (camelCase)

**Columns:**
```dart
id INTEGER PRIMARY KEY AUTOINCREMENT,
uuid TEXT UNIQUE NOT NULL,
farmUuid TEXT NOT NULL,
livestockUuid TEXT NOT NULL,
eventType TEXT NOT NULL, // NEW
startDate TEXT NOT NULL,
endDate TEXT,
birthTypeId INTEGER NOT NULL, // RENAMED from calvingTypeId
birthProblemsId INTEGER, // RENAMED from calvingProblemsId
reproductiveProblemId INTEGER,
remarks TEXT,
status TEXT NOT NULL,
synced INTEGER DEFAULT 0,
syncAction TEXT DEFAULT 'create',
createdAt TEXT NOT NULL,
updatedAt TEXT NOT NULL
```

---

### 2.2 Create Aborted Pregnancy Table
**File:** `lib/features/events/data/tables/aborted_pregnancy_table.dart` (NEW)

**Columns:**
```dart
id INTEGER PRIMARY KEY AUTOINCREMENT,
uuid TEXT UNIQUE NOT NULL,
farmUuid TEXT NOT NULL,
livestockUuid TEXT NOT NULL,
abortionDate TEXT NOT NULL,
reproductiveProblemId INTEGER,
remarks TEXT,
status TEXT NOT NULL,
synced INTEGER DEFAULT 0,
syncAction TEXT DEFAULT 'create',
createdAt TEXT NOT NULL,
updatedAt TEXT NOT NULL
```

---

### 2.3 Update Reference Data Tables
**File:** `lib/features/reference_data/data/tables/birth_type_table.dart` (rename from `calving_type_table.dart`)
**File:** `lib/features/reference_data/data/tables/birth_problem_table.dart` (rename from `calving_problem_table.dart`)

**Changes:**
- Rename tables: `calving_types` → `birth_types`, `calving_problems` → `birth_problems`
- Add `livestockTypeId` column (INTEGER, nullable)

**Birth Type Table:**
```dart
id INTEGER PRIMARY KEY,
name TEXT NOT NULL,
livestockTypeId INTEGER // null = generic
```

**Birth Problem Table:**
```dart
id INTEGER PRIMARY KEY,
name TEXT NOT NULL,
livestockTypeId INTEGER // null = generic
```

---

### 2.4 Update Database Helper
**File:** `lib/database/app_database.dart` or relevant database helper

**Changes:**
- Update table creation methods
- Add migration logic:
  1. Rename `calvings` to `birth_events`
  2. Add `eventType` column to `birth_events`
  3. Rename `calvingTypeId` → `birthTypeId` in `birth_events`
  4. Rename `calvingProblemsId` → `birthProblemsId` in `birth_events`
  5. Rename `calving_types` → `birth_types`
  6. Rename `calving_problems` → `birth_problems`
  7. Add `livestockTypeId` to `birth_types` and `birth_problems`
  8. Create `aborted_pregnancies` table
- Update version number

---

## 📦 Phase 3: Form Updates

### 3.1 Update Calving Form to Birth Event Form
**File:** `lib/features/events/presentation/forms/birth_event_form.dart` (rename from `calving_form.dart`)

**Changes:**
- Rename class from `CalvingForm` to `BirthEventForm`
- Make form species-aware:
  - Get livestock species when form opens
  - Set `eventType` automatically based on species
  - Update labels dynamically:
    - Title: "Calving" or "Farrowing" based on species
    - Offspring label: "Calf" or "Piglet"
- **UPDATE FIELD NAMES:** Use `birthTypeId` and `birthProblemsId` (not `calvingTypeId`/`calvingProblemsId`)
- **UPDATE API CALLS:** Use `/birth-types` and `/birth-problems` endpoints (not `/calving-types`/`/calving-problems`)
- Update API calls to use `/birth-events` endpoint

**Key Logic:**
```dart
// Get livestock to determine event type
final livestock = await getLivestock(livestockUuid);
final species = livestock.speciesName.toLowerCase();
final eventType = species == 'pig' ? 'farrowing' : 'calving';

// Set eventType in form
_formData['eventType'] = eventType;

// Update UI labels
final eventName = eventType == 'farrowing' ? 'Farrowing' : 'Calving';
final offspringName = eventType == 'farrowing' ? 'Piglet' : 'Calf';

// Fetch birth types filtered by livestock type
final birthTypes = await apiService.getBirthTypesByLivestockType(
  livestock.livestockTypeId
);

// Fetch birth problems filtered by livestock type
final birthProblems = await apiService.getBirthProblemsByLivestockType(
  livestock.livestockTypeId
);
```

---

### 3.2 Create Aborted Pregnancy Form
**File:** `lib/features/events/presentation/forms/aborted_pregnancy_form.dart` (NEW)

**Fields:**
- Abortion Date (DatePicker)
- Reproductive Problem (Dropdown - optional)
- Remarks (TextArea - optional)

**Validation:**
- Abortion date is required
- Must be in the past
- Must be after last insemination/pregnancy date
- Only available for pigs (check livestock species)

---

## 📦 Phase 4: UI/UX Updates

### 4.1 Species-Aware Helper Functions
**File:** `lib/features/core/utils/species_helpers.dart` (NEW)

**Functions:**
```dart
// Get parity label based on species
String getParityLabel(String speciesName) {
  return speciesName.toLowerCase() == 'pig' 
    ? 'Parity/Litter Number' 
    : 'Parity/Lactation Number';
}

// Get last birth label
String getLastBirthLabel(String speciesName) {
  return speciesName.toLowerCase() == 'pig' 
    ? 'Date of Last Farrowing' 
    : 'Date of Last Calving';
}

// Get birth event name
String getBirthEventName(String speciesName) {
  return speciesName.toLowerCase() == 'pig' ? 'Farrowing' : 'Calving';
}

// Get offspring name
String getOffspringName(String speciesName) {
  return speciesName.toLowerCase() == 'pig' ? 'Piglet' : 'Calf';
}
```

---

### 4.2 Update Livestock Registration Form
**File:** `lib/features/livestocks/presentation/forms/register_livestock_form.dart` (or similar)

**Changes:**
- Use species-aware labels for parity field
- Use species-aware labels for last birth date
- Filter stages by selected livestock type
- Update terminology based on selected species
- **UPDATE:** Use `/reference/stages/by-livestock-type/{livestockTypeId}` endpoint

---

### 4.3 Update Livestock Details Screen
**File:** `lib/features/livestocks/presentation/livestock_details_screen.dart` (or similar)

**Changes:**
- Show correct terminology based on species
- Display birth events (not just calvings)
- Show aborted pregnancies for pigs
- Filter events by species when displaying
- Use correct labels: "Calving" vs "Farrowing", "Calf" vs "Piglet"

---

### 4.4 Update Events Screen
**File:** `lib/features/events/presentation/events_screen.dart`

**Changes:**
- Add "Aborted Pregnancy" option for pigs
- Show "Calving" or "Farrowing" based on species
- Filter event types based on selected livestock species
- Update event list to show birth events (not calvings)
- Use species-aware labels throughout

---

## 📦 Phase 5: API Integration Updates

### 5.1 Update API Service
**File:** `lib/features/all.additional.data/data/remote/all.additional.data_api.dart` (or relevant API file)

**Changes:**
- **UPDATE endpoint from `/calvings` to `/birth-events`**
- **UPDATE endpoints from `/calving-types` to `/birth-types`**
- **UPDATE endpoints from `/calving-problems` to `/birth-problems`**
- Add endpoint for `/aborted-pregnancies`
- Add endpoint for `/reference/stages/by-livestock-type/{livestockTypeId}`
- **IMPORTANT:** All reference data endpoints now support filtering by `livestockTypeId`

**New/Updated Endpoints:**
```dart
// Birth Events (replaces calvings)
Future<List<BirthEventModel>> getBirthEvents();
Future<BirthEventModel> createBirthEvent(BirthEventModel event);
Future<BirthEventModel> updateBirthEvent(String uuid, BirthEventModel event);
Future<void> deleteBirthEvent(String uuid);

// Birth Types (replaces calving-types)
Future<List<BirthTypeModel>> getBirthTypes({int? livestockTypeId});
Future<List<BirthTypeModel>> getBirthTypesByLivestockType(int livestockTypeId);

// Birth Problems (replaces calving-problems)
Future<List<BirthProblemModel>> getBirthProblems({int? livestockTypeId});
Future<List<BirthProblemModel>> getBirthProblemsByLivestockType(int livestockTypeId);

// Aborted Pregnancies
Future<List<AbortedPregnancyModel>> getAbortedPregnancies();
Future<AbortedPregnancyModel> createAbortedPregnancy(AbortedPregnancyModel event);
Future<AbortedPregnancyModel> updateAbortedPregnancy(String uuid, AbortedPregnancyModel event);
Future<void> deleteAbortedPregnancy(String uuid);

// Reference Data (filtered by livestock type)
Future<List<Stage>> getStagesByLivestockType(int livestockTypeId);
```

**Endpoint URLs:**
```dart
// OLD (deprecated, but may still work for backward compatibility):
GET /api/reference/calving-types/by-livestock-type/{livestockTypeId}
GET /api/reference/calving-problems/by-livestock-type/{livestockTypeId}

// NEW (use these):
GET /api/reference/birth-types?livestockTypeId={livestockTypeId}
GET /api/reference/birth-types/by-livestock-type/{livestockTypeId}
GET /api/reference/birth-problems?livestockTypeId={livestockTypeId}
GET /api/reference/birth-problems/by-livestock-type/{livestockTypeId}
```

---

### 5.2 Update Sync Logic
**File:** `lib/features/core/services/sync_service.dart` (or relevant sync file)

**Changes:**
- **UPDATE sync to use `birth-events` instead of `calvings`**
- **UPDATE field names:** `birthTypeId`, `birthProblemsId` (not `calvingTypeId`/`calvingProblemsId`)
- Add sync for `aborted-pregnancies`
- Update sync response handling for new field names
- Handle `eventType` field in birth events
- **UPDATE reference data sync:** Use `birth-types` and `birth-problems` endpoints

---

### 5.3 Update Repository
**File:** `lib/features/events/data/repository/events_repository.dart`

**Changes:**
- Update methods to use `BirthEventModel` instead of `CalvingModel`
- Add methods for `AbortedPregnancyModel`
- Update save/update/delete methods for new endpoints
- **UPDATE:** Use `birthTypeId` and `birthProblemsId` in all operations
- **UPDATE:** Use `/birth-types` and `/birth-problems` endpoints for reference data

---

## 📦 Phase 6: Localization Updates

### 6.1 Update English Translations
**File:** `lib/l10n/app_en.arb`

**Add/Update:**
```json
{
  "birthEvent": "Birth Event",
  "calving": "Calving",
  "farrowing": "Farrowing",
  "abortedPregnancy": "Aborted Pregnancy",
  "parityLactationNumber": "Parity/Lactation Number",
  "parityLitterNumber": "Parity/Litter Number",
  "dateOfLastCalving": "Date of Last Calving",
  "dateOfLastFarrowing": "Date of Last Farrowing",
  "calf": "Calf",
  "piglet": "Piglet",
  "selectLivestockType": "Select Livestock Type",
  "stagesByLivestockType": "Stages by Livestock Type",
  "birthType": "Birth Type",
  "birthProblem": "Birth Problem"
}
```

---

### 6.2 Update Swahili Translations
**File:** `lib/l10n/app_sw.arb`

**Add/Update:**
```json
{
  "birthEvent": "Tukio la Kuzaliwa",
  "calving": "Kuzalisha",
  "farrowing": "Kuzalisha Nguruwe",
  "abortedPregnancy": "Mimba Iliyokatika",
  "parityLactationNumber": "Nambari ya Uzazi/Kunyonyesha",
  "parityLitterNumber": "Nambari ya Uzazi/Makundi",
  "dateOfLastCalving": "Tarehe ya Kuzalisha Mwisho",
  "dateOfLastFarrowing": "Tarehe ya Kuzalisha Nguruwe Mwisho",
  "calf": "Ndama",
  "piglet": "Nguruwe Mdogo",
  "selectLivestockType": "Chagua Aina ya Mifugo",
  "stagesByLivestockType": "Hatua kwa Aina ya Mifugo",
  "birthType": "Aina ya Kuzaliwa",
  "birthProblem": "Tatizo la Kuzaliwa"
}
```

---

## 📦 Phase 7: Data Migration

### 7.1 Migrate Existing Calving Data
**File:** `lib/database/migrations/migrate_calvings_to_birth_events.dart` (NEW)

**Logic:**
1. Read all records from `calvings` table
2. For each record:
   - Get associated livestock
   - Get livestock species
   - Determine `eventType` (pig = 'farrowing', else = 'calving')
   - **RENAME FIELDS:** `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
   - Insert into `birth_events` table with `eventType`
3. Delete old `calvings` table
4. Update database version

### 7.2 Migrate Reference Data Tables
**File:** `lib/database/migrations/migrate_reference_data_tables.dart` (NEW)

**Logic:**
1. Rename `calving_types` table to `birth_types`
2. Rename `calving_problems` table to `birth_problems`
3. Add `livestockTypeId` column to both tables (nullable)
4. Update all foreign key references in `birth_events` table

---

## ✅ Implementation Checklist

### Models
- [ ] Rename `CalvingModel` to `BirthEventModel`
- [ ] Add `eventType` field to `BirthEventModel`
- [ ] **RENAME FIELDS:** `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- [ ] Create `AbortedPregnancyModel`
- [ ] Create/Update `BirthTypeModel` and `BirthProblemModel`
- [ ] Update `EventLogTypes` constants

### Database
- [ ] Rename `calvings` table to `birth_events`
- [ ] Add `eventType` column to `birth_events` table
- [ ] **RENAME COLUMNS:** `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- [ ] Rename `calving_types` → `birth_types`
- [ ] Rename `calving_problems` → `birth_problems`
- [ ] Add `livestockTypeId` to `birth_types` and `birth_problems` tables
- [ ] Create `aborted_pregnancies` table
- [ ] Update database version
- [ ] Create migration script for existing data

### Forms
- [ ] Rename `CalvingForm` to `BirthEventForm`
- [ ] Make form species-aware
- [ ] Update labels dynamically
- [ ] **UPDATE:** Use `birthTypeId` and `birthProblemsId` fields
- [ ] **UPDATE:** Use `/birth-types` and `/birth-problems` API endpoints
- [ ] Create `AbortedPregnancyForm`

### UI/Helpers
- [ ] Create species-aware helper functions
- [ ] Update livestock registration form
- [ ] Update livestock details screen
- [ ] Update events screen
- [ ] Add aborted pregnancy option for pigs

### API Integration
- [ ] **UPDATE:** Change `/calvings` → `/birth-events`
- [ ] **UPDATE:** Change `/calving-types` → `/birth-types`
- [ ] **UPDATE:** Change `/calving-problems` → `/birth-problems`
- [ ] Add `/aborted-pregnancies` endpoint
- [ ] Update sync logic with new field names
- [ ] Update repository methods
- [ ] Test API calls

### Localization
- [ ] Update English translations
- [ ] Update Swahili translations
- [ ] Run localization generation

### Testing
- [ ] Test birth event creation for cattle (calving)
- [ ] Test birth event creation for pigs (farrowing)
- [ ] Test aborted pregnancy creation
- [ ] Test species-aware labels
- [ ] Test stages filtering by livestock type
- [ ] Test birth types/problems filtering by livestock type
- [ ] Test data migration

---

## 🔄 Migration Strategy

### Step 1: Database Migration
1. Create new `birth_events` table
2. Migrate existing `calvings` data with `eventType` and renamed fields
3. Rename `calving_types` → `birth_types`
4. Rename `calving_problems` → `birth_problems`
5. Add `livestockTypeId` to reference tables
6. Create `aborted_pregnancies` table
7. Drop old `calvings` table

### Step 2: Model Updates
1. Update models to match new structure
2. Update all references from `Calving` to `BirthEvent`
3. **UPDATE:** Change field names to `birthTypeId` and `birthProblemsId`

### Step 3: UI Updates
1. Update forms to be species-aware
2. Update labels and terminology
3. Add new aborted pregnancy form
4. **UPDATE:** Use new API endpoints for reference data

### Step 4: API Updates
1. **UPDATE:** Change all endpoints to use new names
2. Update sync logic
3. Test all API calls

---

## 📊 File Changes Summary

| Category | Files to Create | Files to Update | Files to Delete |
|----------|----------------|-----------------|-----------------|
| **Models** | 2 (AbortedPregnancyModel, BirthTypeModel, BirthProblemModel) | 1 (CalvingModel → BirthEventModel) | 0 |
| **Database** | 1 (aborted_pregnancy_table) | 2 (calving_table → birth_event_table, calving_type_table → birth_type_table, calving_problem_table → birth_problem_table) | 0 |
| **Forms** | 1 (AbortedPregnancyForm) | 1 (CalvingForm → BirthEventForm) | 0 |
| **API** | 0 | 3-5 (API service, repository, sync) | 0 |
| **UI/Helpers** | 1 (species_helpers) | 3-5 (screens, forms) | 0 |
| **Localization** | 0 | 2 (en, sw) | 0 |

**Total:** ~18-25 files to create/update

---

## 🚨 Important Notes

### Backend Changes Summary:
1. **Table Renames:**
   - `calvings` → `birth_events` ✅
   - `calving_types` → `birth_types` ✅
   - `calving_problems` → `birth_problems` ✅

2. **Column Renames in birth_events:**
   - `calvingTypeId` → `birthTypeId` ✅
   - `calvingProblemsId` → `birthProblemsId` ✅

3. **New Endpoints:**
   - `/api/logs/birth-events` (replaces `/api/logs/calvings`)
   - `/api/reference/birth-types` (replaces `/api/reference/calving-types`)
   - `/api/reference/birth-problems` (replaces `/api/reference/calving-problems`)
   - `/api/logs/aborted-pregnancies` (new)

4. **Reference Data Filtering:**
   - All reference data endpoints now support `?livestockTypeId=X` query parameter
   - Generic types (where `livestockTypeId` is null) are included when filtering

### Backward Compatibility:
- Old endpoints may still work but are deprecated
- Migration script must handle existing calving data
- Default `eventType` to 'calving' if species cannot be determined

### Data Integrity:
- Ensure all calvings have associated livestock before migration
- Validate `eventType` matches species before saving
- **IMPORTANT:** Update all field references from `calvingTypeId`/`calvingProblemsId` to `birthTypeId`/`birthProblemsId`

### UI Consistency:
- All labels must be species-aware
- Forms must auto-detect species and set correct terminology
- Reference data dropdowns must filter by livestock type

### Testing Priority:
- Test migration on staging first
- Test with both cattle and pig data
- Verify sync works correctly with new field names
- Test reference data filtering by livestock type

---

## 📅 Estimated Timeline

- **Phase 1 (Models):** 2-3 hours
- **Phase 2 (Database):** 3-4 hours (includes table/column renames)
- **Phase 3 (Forms):** 3-4 hours
- **Phase 4 (UI):** 2-3 hours
- **Phase 5 (API):** 3-4 hours (includes endpoint updates)
- **Phase 6 (Localization):** 1 hour
- **Phase 7 (Migration):** 3-4 hours

**Total Estimated Time:** 17-23 hours

---

## 🔗 Related Backend Changes

This frontend plan is based on the following backend changes:
- `birth_events` table replaces `calvings`
- `eventType` enum field ('calving', 'farrowing')
- `birth_types` table replaces `calving_types` (generic for all livestock)
- `birth_problems` table replaces `calving_problems` (generic for all livestock)
- Column renames: `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- `aborted_pregnancies` table for pigs
- `stages` table with `livestockTypeId`
- Reference data filtering by livestock type

See: `BACKEND_IMPLEMENTATION_SUMMARY.md` for complete backend details.

---

**End of Frontend Implementation Plan**
