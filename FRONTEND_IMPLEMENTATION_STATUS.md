# Frontend Multi-Livestock Implementation Status

**Date:** 2025-11-30  
**Status:** Phase 2 (Database) Complete, Starting Phase 1 (Models)

---

## ✅ Completed Phases

### Phase 2: Database Schema Updates ✅
- ✅ `birth_events` table created (replaces `calvings`)
- ✅ `aborted_pregnancies` table created
- ✅ `birth_types` table created (with `livestockTypeId`)
- ✅ `birth_problems` table created (with `livestockTypeId`)
- ✅ Database migration script implemented (version 15)
- ✅ Migration handles data migration from `calvings` to `birth_events`
- ✅ Column renames handled: `calvingTypeId` → `birthTypeId`, `calvingProblemsId` → `birthProblemsId`
- ✅ Table renames handled: `calving_types` → `birth_types`, `calving_problems` → `birth_problems`

---

## ✅ Completed Phases (Updated)

### Phase 1: Model Updates ✅
- ✅ `BirthEventModel` created (replaces `CalvingModel`)
  - Includes `eventType` field ('calving' or 'farrowing')
  - Uses `birthTypeId` and `birthProblemsId` (renamed fields)
  - Helper methods: `getEventName()`, `getOffspringName()`
  - Migration support: `fromCalvingModel()` factory
- ✅ `AbortedPregnancyModel` created
- ✅ `BirthTypeModel` created (replaces `CalvingType`)
  - Includes `livestockTypeId` field
  - Helper methods for filtering
- ✅ `BirthProblemModel` created (replaces `CalvingProblem`)
  - Includes `livestockTypeId` field
  - Helper methods for filtering
- ✅ `EventLogTypes` constants updated
  - Added `farrowing` constant
  - Added `abortedPregnancy` constant
  - Added `getBirthEventType()` helper method

## ❌ Pending Phases

### Phase 3: Form Updates ❌
- ❌ `BirthEventForm` not created (still using `CalvingForm`)
- ❌ Form not species-aware (no dynamic labels)
- ❌ Still using `calvingTypeId`/`calvingProblemsId` instead of `birthTypeId`/`birthProblemsId`
- ❌ `AbortedPregnancyForm` not created

### Phase 4: UI/UX Updates ❌
- ❌ Species-aware helper functions not created
- ❌ Livestock registration form not updated
- ❌ Livestock details screen not updated
- ❌ Events screen not updated

### Phase 5: API Integration Updates ❌
- ❌ API endpoints still using `/calvings` (should be `/birth-events`)
- ❌ API endpoints still using `/calving-types` (should be `/birth-types`)
- ❌ API endpoints still using `/calving-problems` (should be `/birth-problems`)
- ❌ `/aborted-pregnancies` endpoint not added
- ❌ Sync logic not updated

### Phase 6: Localization Updates ❌
- ❌ English translations not updated
- ❌ Swahili translations not updated

### Phase 7: Data Migration ❌
- ✅ Database migration complete (handled in Phase 2)
- ❌ Model migration (update all references from `Calving` to `BirthEvent`)

---

## 📋 Next Steps (Priority Order)

### 1. Phase 1: Model Updates (CURRENT)
1. Create `BirthEventModel` with:
   - `eventType` field ('calving' or 'farrowing')
   - `birthTypeId` (renamed from `calvingTypeId`)
   - `birthProblemsId` (renamed from `calvingProblemsId`)
   - Helper methods: `getEventName()`, `getOffspringName()`

2. Create `AbortedPregnancyModel`

3. Create `BirthTypeModel` and `BirthProblemModel` (or update existing models)

4. Update `EventLogTypes` constants

### 2. Phase 3: Form Updates
1. Create `BirthEventForm` (replace `CalvingForm`)
   - Make species-aware
   - Use `birthTypeId`/`birthProblemsId`
   - Use new API endpoints

2. Create `AbortedPregnancyForm`

### 3. Phase 5: API Integration
1. Update API service endpoints
2. Update sync logic
3. Update repository methods

### 4. Phase 4: UI/UX Updates
1. Create species-aware helpers
2. Update screens and forms

### 5. Phase 6: Localization
1. Update translation files

---

## 🔍 Current File Status

### Models
- ✅ `birth_event_table.dart` - EXISTS
- ✅ `birth_event_model.dart` - CREATED ✅
- ✅ `aborted_pregnancy_table.dart` - EXISTS
- ✅ `aborted_pregnancy_model.dart` - CREATED ✅
- ✅ `birth_type_table.dart` - EXISTS
- ✅ `birth_type_model.dart` - CREATED ✅
- ✅ `birth_problem_table.dart` - EXISTS
- ✅ `birth_problem_model.dart` - CREATED ✅
- ✅ `event_log_types.dart` - UPDATED ✅

### Forms
- ❌ `birth_event_form.dart` - MISSING (still using `calving_form.dart`)
- ❌ `aborted_pregnancy_form.dart` - MISSING

### Database
- ✅ `app_database.dart` - UPDATED (version 15, migration complete)

---

## ⚠️ Important Notes

1. **Backend is 100% complete** - All endpoints ready:
   - `/api/logs/birth-events` (replaces `/api/logs/calvings`)
   - `/api/reference/birth-types` (replaces `/api/reference/calving-types`)
   - `/api/reference/birth-problems` (replaces `/api/reference/calving-problems`)
   - `/api/logs/aborted-pregnancies` (new)

2. **Field Name Changes:**
   - `calvingTypeId` → `birthTypeId`
   - `calvingProblemsId` → `birthProblemsId`

3. **Table Name Changes:**
   - `calvings` → `birth_events`
   - `calving_types` → `birth_types`
   - `calving_problems` → `birth_problems`

4. **New Field:**
   - `eventType` ('calving' or 'farrowing') in `birth_events`

---

**Next Action:** Start Phase 3 - Create forms (BirthEventForm and AbortedPregnancyForm)

---

## 📝 Phase 1 Implementation Summary

### Files Created:
1. ✅ `lib/features/events/domain/model/birth_event_model.dart`
2. ✅ `lib/features/events/domain/model/aborted_pregnancy_model.dart`
3. ✅ `lib/features/all.logs.additional.data/domain/models/birth_type.dart`
4. ✅ `lib/features/all.logs.additional.data/domain/models/birth_problem.dart`

### Files Updated:
1. ✅ `lib/features/events/domain/constants/event_log_types.dart`

### Key Features:
- `BirthEventModel` supports both calving and farrowing via `eventType` field
- Backward compatibility: `fromJson()` supports both `birthTypeId`/`calvingTypeId` and `birthProblemsId`/`calvingProblemsId`
- Migration helper: `fromCalvingModel()` factory method
- Species-aware helper methods in `BirthEventModel`
- Generic and species-specific filtering support in `BirthType` and `BirthProblem` models

