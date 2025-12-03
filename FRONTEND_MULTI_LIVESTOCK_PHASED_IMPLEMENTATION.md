# Frontend Multi-Livestock Support - Phased Implementation Plan

**Version:** 3.0  
**Date:** 2025-11-30  
**Status:** Ready for Implementation

---

## 📋 Current Implementation Analysis

### Architecture Overview
- **Database:** Drift ORM (local-first, offline support)
- **Current Database Version:** 14
- **Sync Strategy:** 
  - POST: Send unsynced local data to server
  - GET: Fetch latest data from server with timestamp-based conflict resolution
- **Localization:** English (`app_en.arb`) and Swahili (`app_sw.arb`)

### Current Calving Implementation
- ✅ **Table:** `Calvings` (Drift table) - exists
- ✅ **Model:** `CalvingModel` - exists
- ✅ **Form:** `CalvingFormScreen` - exists
- ⚠️ **DAO:** NOT in `EventDao` (needs to be added)
- ⚠️ **Repository:** Methods exist but return "coming soon" dialog
- ✅ **Reference Data:** `CalvingTypes` and `CalvingProblems` tables exist
- ✅ **Sync:** Not yet integrated into sync flow

### Files to Modify/Create

**Database Tables:**
- `lib/features/events/data/tables/calving_table.dart` → Rename to `birth_event_table.dart`
- `lib/features/all.logs.additional.data/data/local/tables/calving_type_table.dart` → Rename to `birth_type_table.dart`
- `lib/features/all.logs.additional.data/data/local/tables/calving_problem_table.dart` → Rename to `birth_problem_table.dart`
- `lib/features/events/data/tables/aborted_pregnancy_table.dart` → **NEW**

**Models:**
- `lib/features/events/domain/model/calving_model.dart` → Rename to `birth_event_model.dart`
- `lib/features/all.logs.additional.data/domain/models/calving_type.dart` → Rename to `birth_type.dart`
- `lib/features/all.logs.additional.data/domain/models/calving_problem.dart` → Rename to `birth_problem.dart`
- `lib/features/events/domain/model/aborted_pregnancy_model.dart` → **NEW**

**Forms:**
- `lib/features/events/presentation/forms/calving_form.dart` → Rename to `birth_event_form.dart`
- `lib/features/events/presentation/forms/aborted_pregnancy_form.dart` → **NEW**

**DAO/Repository:**
- `lib/database/daos/event_dao.dart` → Add birth events and aborted pregnancies
- `lib/features/events/data/repository/events_repository.dart` → Implement birth events methods
- `lib/database/daos/log_reference_dao.dart` → Update for birth types/problems

**Sync:**
- `lib/core/global-sync/sync.dart` → Add birth events and aborted pregnancies to sync flow

**UI/Constants:**
- `lib/features/events/domain/constants/event_log_types.dart` → Add farrowing and aborted pregnancy
- `lib/features/events/presentation/events_screen.dart` → Update event types
- `lib/features/events/presentation/provider/events_provider.dart` → Implement birth events methods

**Localization:**
- `lib/l10n/app_en.arb` → Add new keys
- `lib/l10n/app_sw.arb` → Add new keys

**Database:**
- `lib/database/app_database.dart` → Update schema version, add migrations, register new tables

---

## 🎯 Implementation Phases

### **PHASE 1: Database Schema Updates** (Foundation)
**Goal:** Update database tables and schema to support multi-livestock

#### Step 1.1: Create New Tables
**Files to Create:**
1. `lib/features/events/data/tables/birth_event_table.dart` (rename from calving_table.dart)
2. `lib/features/events/data/tables/aborted_pregnancy_table.dart` (NEW)
3. `lib/features/all.logs.additional.data/data/local/tables/birth_type_table.dart` (rename from calving_type_table.dart)
4. `lib/features/all.logs.additional.data/data/local/tables/birth_problem_table.dart` (rename from calving_problem_table.dart)

**Changes:**
- Rename `Calvings` → `BirthEvents`
- Add `eventType` column (TEXT, NOT NULL)
- Rename `calvingTypeId` → `birthTypeId`
- Rename `calvingProblemsId` → `birthProblemsId`
- Add `livestockTypeId` to `BirthTypes` and `BirthProblems` tables (INTEGER, nullable)

#### Step 1.2: Update Database Registration
**File:** `lib/database/app_database.dart`

**Changes:**
- Increment `schemaVersion` from 14 → 15
- Add new tables to `@DriftDatabase(tables: [...])`:
  - `BirthEvents` (replaces `Calvings`)
  - `AbortedPregnancies` (NEW)
  - `BirthTypes` (replaces `CalvingTypes`)
  - `BirthProblems` (replaces `CalvingProblems`)
- Add migration logic in `onUpgrade`:
  ```dart
  if (from < 15) {
    // Step 1: Create new birth_events table
    await m.createTable(birthEvents);
    
    // Step 2: Migrate data from calvings to birth_events
    await m.customStatement('''
      INSERT INTO birth_events (
        id, uuid, farmUuid, livestockUuid, eventType, startDate, endDate,
        birthTypeId, birthProblemsId, reproductiveProblemId, remarks, status,
        synced, syncAction, createdAt, updatedAt
      )
      SELECT 
        id, uuid, farmUuid, livestockUuid,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM livestocks l 
            JOIN species s ON l.speciesId = s.id 
            WHERE l.uuid = calvings.livestockUuid 
            AND LOWER(s.name) = 'pig'
          ) THEN 'farrowing'
          ELSE 'calving'
        END as eventType,
        startDate, endDate,
        calvingTypeId as birthTypeId,
        calvingProblemsId as birthProblemsId,
        reproductiveProblemId, remarks, status,
        synced, syncAction, createdAt, updatedAt
      FROM calvings
    ''');
    
    // Step 3: Drop old calvings table
    await m.deleteTable('calvings');
    
    // Step 4: Rename calving_types to birth_types
    await m.renameTable('calving_types', 'birth_types');
    
    // Step 5: Add livestockTypeId to birth_types
    await m.addColumn(birthTypes, birthTypes.livestockTypeId);
    
    // Step 6: Rename calving_problems to birth_problems
    await m.renameTable('calving_problems', 'birth_problems');
    
    // Step 7: Add livestockTypeId to birth_problems
    await m.addColumn(birthProblems, birthProblems.livestockTypeId);
    
    // Step 8: Create aborted_pregnancies table
    await m.createTable(abortedPregnancies);
  }
  ```

**Estimated Time:** 2-3 hours

---

### **PHASE 2: Domain Models** (Data Layer)
**Goal:** Create/update models to match new backend structure

#### Step 2.1: Create BirthEventModel
**File:** `lib/features/events/domain/model/birth_event_model.dart` (rename from calving_model.dart)

**Changes:**
```dart
class BirthEventModel {
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

  // Helper methods
  String getEventName() => eventType == 'farrowing' ? 'Farrowing' : 'Calving';
  String getOffspringName() => eventType == 'farrowing' ? 'Piglet' : 'Calf';
  
  // Update toJson/fromJson to use birthTypeId, birthProblemsId
  // Update toApiJson to use birthTypeId, birthProblemsId, eventType
}
```

#### Step 2.2: Create AbortedPregnancyModel
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

#### Step 2.3: Update Reference Data Models
**Files:**
- `lib/features/all.logs.additional.data/domain/models/birth_type.dart` (rename from calving_type.dart)
- `lib/features/all.logs.additional.data/domain/models/birth_problem.dart` (rename from calving_problem.dart)

**Changes:**
- Rename classes: `CalvingType` → `BirthType`, `CalvingProblem` → `BirthProblem`
- Add `livestockTypeId` field (int?, nullable)

**Estimated Time:** 1-2 hours

---

### **PHASE 3: Database Access Layer (DAO)** (Data Access)
**Goal:** Add database operations for birth events and aborted pregnancies

#### Step 3.1: Update EventDao
**File:** `lib/database/daos/event_dao.dart`

**Changes:**
1. Add `BirthEvents` and `AbortedPregnancies` to `@DriftAccessor(tables: [...])`
2. Add methods for BirthEvents:
   ```dart
   // UPSERT
   Future<void> upsertBirthEvents(List<BirthEventsCompanion> entries);
   Future<BirthEvent> upsertBirthEvent(BirthEventsCompanion entry);
   
   // GETTERS
   Future<BirthEvent?> getBirthEventByUuid(String uuid);
   Future<List<BirthEvent>> getBirthEvents({String? farmUuid, String? livestockUuid});
   Future<List<BirthEvent>> getUnsyncedBirthEvents();
   
   // UPDATE/DELETE
   Future<bool> updateBirthEvent(BirthEvent entry);
   Future<int> deleteBirthEventByUuid(String uuid);
   Future<int> deleteServerBirthEventsNotIn(Set<String> uuids);
   ```
3. Add methods for AbortedPregnancies (similar pattern)

#### Step 3.2: Update LogReferenceDao
**File:** `lib/database/daos/log_reference_dao.dart`

**Changes:**
- Update methods to use `BirthTypes` and `BirthProblems` instead of `CalvingTypes` and `CalvingProblems`
- Add filtering by `livestockTypeId`:
  ```dart
  Future<List<BirthType>> getBirthTypesByLivestockType(int? livestockTypeId);
  Future<List<BirthProblem>> getBirthProblemsByLivestockType(int? livestockTypeId);
  ```

**Estimated Time:** 2-3 hours

---

### **PHASE 4: Repository Layer** (Business Logic)
**Goal:** Implement repository methods for birth events and aborted pregnancies

#### Step 4.1: Update EventsRepository
**File:** `lib/features/events/data/repository/events_repository.dart`

**Changes:**
1. Add sync methods:
   ```dart
   Future<void> _syncBirthEvents(dynamic payload);
   Future<void> _syncAbortedPregnancies(dynamic payload);
   ```
   Update `syncLogs()` to include:
   ```dart
   await _syncBirthEvents(logs['birthEvents']);
   await _syncAbortedPregnancies(logs['abortedPregnancies']);
   ```

2. Add CRUD methods:
   ```dart
   Future<List<BirthEventModel>> getBirthEvents({String? farmUuid, String? livestockUuid});
   Future<BirthEventModel?> getBirthEventByUuid(String uuid);
   Future<BirthEventModel> createBirthEvent(BirthEventModel model);
   Future<BirthEventModel> updateBirthEvent(BirthEventModel model);
   Future<void> deleteBirthEvent(String uuid);
   
   // Similar for AbortedPregnancyModel
   ```

3. Add unsynced data methods:
   ```dart
   Future<List<Map<String, dynamic>>> getUnsyncedBirthEventsForApi();
   Future<List<Map<String, dynamic>>> getUnsyncedAbortedPregnanciesForApi();
   ```

4. Add mark as synced methods:
   ```dart
   Future<void> markBirthEventsAsSynced(List<String> uuids);
   Future<void> markAbortedPregnanciesAsSynced(List<String> uuids);
   ```

#### Step 4.2: Update LogAdditionalDataRepository
**File:** `lib/features/all.logs.additional.data/data/repository/log_additional_data_repository.dart`

**Changes:**
- Update `fetchRemoteLogAdditionalData()` to use `birthTypes` and `birthProblems` keys
- Update `storeLogAdditionalData()` to handle new table names and `livestockTypeId` field

**Estimated Time:** 3-4 hours

---

### **PHASE 5: Sync Integration** (Data Synchronization)
**Goal:** Integrate birth events and aborted pregnancies into sync flow

#### Step 5.1: Update Sync Service
**File:** `lib/core/global-sync/sync.dart`

**Changes:**
1. Update `_collectUnsyncedData()`:
   ```dart
   final unsyncedBirthEvents = await eventsRepository.getUnsyncedBirthEventsForApi();
   final unsyncedAbortedPregnancies = await eventsRepository.getUnsyncedAbortedPregnanciesForApi();
   
   return {
     // ... existing
     'logs': {
       // ... existing
       'birthEvents': unsyncedBirthEvents,
       'abortedPregnancies': unsyncedAbortedPregnancies,
     },
   };
   ```

2. Update `_markItemsAsSynced()`:
   ```dart
   final syncedBirthEvents = _extractUuids(syncedLogs['birthEvents']);
   if (syncedBirthEvents.isNotEmpty) {
     await eventsRepository.markBirthEventsAsSynced(syncedBirthEvents);
   }
   
   final syncedAbortedPregnancies = _extractUuids(syncedLogs['abortedPregnancies']);
   if (syncedAbortedPregnancies.isNotEmpty) {
     await eventsRepository.markAbortedPregnanciesAsSynced(syncedAbortedPregnancies);
   }
   ```

3. Update `_storeUserSpecificData()`:
   ```dart
   // In syncLogs call, ensure birthEvents and abortedPregnancies are included
   ```

4. Update `getUnsyncedSummary()`:
   ```dart
   final birthEvents = await eventsRepository.getUnsyncedBirthEventsForApi();
   final abortedPregnancies = await eventsRepository.getUnsyncedAbortedPregnanciesForApi();
   
   final logCounts = <String, int>{
     // ... existing
     EventLogTypes.birthEvent: birthEvents.length,
     EventLogTypes.abortedPregnancy: abortedPregnancies.length,
   };
   ```

**Estimated Time:** 2-3 hours

---

### **PHASE 6: Provider Layer** (State Management)
**Goal:** Update EventsProvider to handle birth events

#### Step 6.1: Update EventsProvider
**File:** `lib/features/events/presentation/provider/events_provider.dart`

**Changes:**
1. Add state variables:
   ```dart
   List<BirthEventModel> _birthEvents = const [];
   List<AbortedPregnancyModel> _abortedPregnancies = const [];
   ```

2. Implement methods (replace "coming soon" dialogs):
   ```dart
   Future<BirthEventModel?> addBirthEventWithDialog(BuildContext context, BirthEventModel model);
   Future<BirthEventModel?> updateBirthEventWithDialog(BuildContext context, BirthEventModel model);
   Future<void> deleteBirthEventWithDialog(BuildContext context, String uuid);
   
   // Similar for AbortedPregnancyModel
   ```

3. Add load methods:
   ```dart
   Future<void> loadBirthEventsForLivestock({required String farmUuid, required String livestockUuid});
   ```

**Estimated Time:** 2-3 hours

---

### **PHASE 7: Forms & UI** (User Interface)
**Goal:** Update forms to be species-aware and support new models

#### Step 7.1: Create Species Helper
**File:** `lib/features/core/utils/species_helpers.dart` (NEW)

**Content:**
```dart
class SpeciesHelpers {
  static String getParityLabel(String speciesName) {
    return speciesName.toLowerCase() == 'pig' 
      ? 'Parity/Litter Number' 
      : 'Parity/Lactation Number';
  }

  static String getLastBirthLabel(String speciesName) {
    return speciesName.toLowerCase() == 'pig' 
      ? 'Date of Last Farrowing' 
      : 'Date of Last Calving';
  }

  static String getBirthEventName(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? 'Farrowing' : 'Calving';
  }

  static String getOffspringName(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? 'Piglet' : 'Calf';
  }

  static String getBirthEventType(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? 'farrowing' : 'calving';
  }
}
```

#### Step 7.2: Update Birth Event Form
**File:** `lib/features/events/presentation/forms/birth_event_form.dart` (rename from calving_form.dart)

**Changes:**
1. Rename class: `CalvingFormScreen` → `BirthEventFormScreen`
2. Update model references: `CalvingModel` → `BirthEventModel`
3. Add species detection:
   ```dart
   String? _selectedLivestockSpecies;
   String? _eventType; // 'calving' or 'farrowing'
   
   Future<void> _loadLivestockSpecies() async {
     if (_selectedLivestockUuid == null) return;
     final livestock = await database.livestockDao.getLivestockByUuid(_selectedLivestockUuid!);
     if (livestock != null) {
       final species = await database.specieDao.getSpecieById(livestock.speciesId);
       setState(() {
         _selectedLivestockSpecies = species?.name.toLowerCase();
         _eventType = SpeciesHelpers.getBirthEventType(species?.name ?? '');
       });
     }
   }
   ```

4. Update field names:
   - `_selectedCalvingTypeId` → `_selectedBirthTypeId`
   - `_selectedCalvingProblemId` → `_selectedBirthProblemId`
   - `_calvingTypeItems` → `_birthTypeItems`
   - `_calvingProblemItems` → `_birthProblemItems`

5. Update reference data loading to filter by livestock type:
   ```dart
   Future<void> _loadReferenceData() async {
     // Get livestock type from selected livestock
     final livestock = await database.livestockDao.getLivestockByUuid(_selectedLivestockUuid);
     final livestockTypeId = livestock?.livestockTypeId;
     
     final provider = Provider.of<LogAdditionalDataProvider>(context, listen: false);
     await provider.ensureLoaded();
     
     setState(() {
       _birthTypeItems = provider.birthTypes
         .where((type) => type.livestockTypeId == livestockTypeId || type.livestockTypeId == null)
         .map((type) => DropdownItem<int>(value: type.id, label: type.name))
         .toList();
       
       _birthProblemItems = provider.birthProblems
         .where((problem) => problem.livestockTypeId == livestockTypeId || problem.livestockTypeId == null)
         .map((problem) => DropdownItem<int>(value: problem.id, label: problem.name))
         .toList();
     });
   }
   ```

6. Update labels dynamically:
   ```dart
   final eventName = _eventType == 'farrowing' ? l10n.farrowing : l10n.calving;
   final offspringName = _eventType == 'farrowing' ? l10n.piglet : l10n.calf;
   ```

7. Update form submission to include `eventType`:
   ```dart
   final newModel = BirthEventModel(
     // ... existing fields
     eventType: _eventType ?? 'calving',
     birthTypeId: _selectedBirthTypeId!,
     birthProblemsId: _selectedBirthProblemId,
     // ...
   );
   ```

#### Step 7.3: Create Aborted Pregnancy Form
**File:** `lib/features/events/presentation/forms/aborted_pregnancy_form.dart` (NEW)

**Structure:** Similar to birth event form but simpler (only abortion date, reproductive problem, remarks)

#### Step 7.4: Update Events Screen
**File:** `lib/features/events/presentation/events_screen.dart`

**Changes:**
- Update `EventLogTypes.calving` → `EventLogTypes.birthEvent`
- Add `EventLogTypes.abortedPregnancy` option (only show for pigs)
- Update navigation to use `BirthEventFormScreen`

**Estimated Time:** 4-5 hours

---

### **PHASE 8: Localization** (Internationalization)
**Goal:** Add/update localization keys for new terminology

#### Step 8.1: Update English Localization
**File:** `lib/l10n/app_en.arb`

**Add/Update:**
```json
{
  "birthEvent": "Birth Event",
  "farrowing": "Farrowing",
  "abortedPregnancy": "Aborted Pregnancy",
  "parityLactationNumber": "Parity/Lactation Number",
  "parityLitterNumber": "Parity/Litter Number",
  "dateOfLastCalving": "Date of Last Calving",
  "dateOfLastFarrowing": "Date of Last Farrowing",
  "calf": "Calf",
  "piglet": "Piglet",
  "birthType": "Birth Type",
  "birthProblem": "Birth Problem",
  "addBirthEvent": "Add birth event",
  "editBirthEvent": "Edit birth event",
  "addAbortedPregnancy": "Add aborted pregnancy",
  "editAbortedPregnancy": "Edit aborted pregnancy",
  "birthEventDetailsSubtitle": "Record birth outcomes and supporting details.",
  "birthEventNotesSubtitle": "Capture observations, issues, or follow-up actions.",
  "birthTypeRequired": "Birth type is required",
  "ensureBirthEventDetailsAccuracy": "Ensure birth information is accurate before saving.",
  "confirmSaveBirthEvent": "Save birth event log?",
  "confirmUpdateBirthEvent": "Update birth event log?",
  "birthEventLogSaveFailed": "Failed to save birth event log. Please try again."
}
```

#### Step 8.2: Update Swahili Localization
**File:** `lib/l10n/app_sw.arb`

**Add/Update:** (Swahili translations for all new keys)

#### Step 8.3: Regenerate Localization
**Command:**
```bash
flutter gen-l10n
```

**Estimated Time:** 1 hour

---

### **PHASE 9: Constants & Event Types** (Configuration)
**Goal:** Update event type constants

#### Step 9.1: Update EventLogTypes
**File:** `lib/features/events/domain/constants/event_log_types.dart`

**Changes:**
```dart
class EventLogTypes {
  // ... existing
  static const birthEvent = 'birthEvent'; // Replaces calving
  static const farrowing = 'farrowing';
  static const abortedPregnancy = 'abortedPregnancy';
  
  // Helper method
  static String getBirthEventType(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? farrowing : birthEvent;
  }
}
```

**Estimated Time:** 30 minutes

---

### **PHASE 10: Testing & Validation** (Quality Assurance)
**Goal:** Test all changes and ensure data integrity

#### Step 10.1: Database Migration Testing
- Test migration from version 14 → 15
- Verify data migration from `calvings` → `birth_events`
- Verify table renames work correctly
- Test with existing data

#### Step 10.2: Sync Testing
- Test POST sync with unsynced birth events
- Test GET sync with server birth events
- Test conflict resolution (timestamp-based)
- Test aborted pregnancies sync

#### Step 10.3: Form Testing
- Test birth event form for cattle (calving)
- Test birth event form for pigs (farrowing)
- Test species-aware labels
- Test reference data filtering by livestock type
- Test aborted pregnancy form (pigs only)

#### Step 10.4: UI Testing
- Test events screen shows correct event types
- Test localization (English/Swahili)
- Test offline functionality
- Test error handling

**Estimated Time:** 4-5 hours

---

## 📊 Implementation Summary

### Phase Breakdown

| Phase | Description | Files | Estimated Time |
|-------|-------------|-------|----------------|
| **Phase 1** | Database Schema Updates | 5 files | 2-3 hours |
| **Phase 2** | Domain Models | 4 files | 1-2 hours |
| **Phase 3** | Database Access Layer (DAO) | 2 files | 2-3 hours |
| **Phase 4** | Repository Layer | 2 files | 3-4 hours |
| **Phase 5** | Sync Integration | 1 file | 2-3 hours |
| **Phase 6** | Provider Layer | 1 file | 2-3 hours |
| **Phase 7** | Forms & UI | 4 files | 4-5 hours |
| **Phase 8** | Localization | 2 files | 1 hour |
| **Phase 9** | Constants | 1 file | 30 min |
| **Phase 10** | Testing | All files | 4-5 hours |
| **TOTAL** | | **~22 files** | **22-29 hours** |

---

## 🔄 Migration Strategy

### Database Migration Flow

1. **Backup:** Ensure database backup before migration
2. **Version Check:** Current version is 14, migrate to 15
3. **Migration Steps:**
   - Create `birth_events` table
   - Migrate data from `calvings` with `eventType` determination
   - Drop `calvings` table
   - Rename `calving_types` → `birth_types`
   - Add `livestockTypeId` to `birth_types`
   - Rename `calving_problems` → `birth_problems`
   - Add `livestockTypeId` to `birth_problems`
   - Create `aborted_pregnancies` table

### Data Migration Logic

```dart
// Determine eventType based on livestock species
CASE 
  WHEN EXISTS (
    SELECT 1 FROM livestocks l 
    JOIN species s ON l.speciesId = s.id 
    WHERE l.uuid = calvings.livestockUuid 
    AND LOWER(s.name) = 'pig'
  ) THEN 'farrowing'
  ELSE 'calving'
END as eventType
```

---

## ⚠️ Critical Considerations

### 1. Backward Compatibility
- Old `CalvingModel` references need to be updated
- Sync payload structure changes (backend expects `birthEvents`, not `calvings`)
- API endpoints change (`/birth-events` instead of `/calvings`)

### 2. Data Integrity
- Ensure all existing calvings have associated livestock before migration
- Validate `eventType` matches species before saving
- Handle cases where species cannot be determined (default to 'calving')

### 3. Local-First Architecture
- All changes must work offline
- Sync must handle both directions (POST and GET)
- Conflict resolution must use timestamps

### 4. Species-Aware UI
- Forms must auto-detect species
- Labels must update dynamically
- Reference data must filter by livestock type
- Aborted pregnancy only available for pigs

### 5. Testing Priority
- Test migration on staging first
- Test with both cattle and pig data
- Verify sync works correctly
- Test offline functionality

---

## 🚀 Quick Start Checklist

### Before Starting:
- [ ] Backup current database
- [ ] Review backend API endpoints
- [ ] Understand current sync flow
- [ ] Review localization structure

### Phase 1 (Database):
- [ ] Create new table files
- [ ] Update app_database.dart
- [ ] Test migration script
- [ ] Verify data migration

### Phase 2 (Models):
- [ ] Create/rename model files
- [ ] Update field names
- [ ] Add helper methods
- [ ] Test JSON serialization

### Phase 3 (DAO):
- [ ] Update EventDao
- [ ] Update LogReferenceDao
- [ ] Test database operations
- [ ] Verify queries

### Phase 4 (Repository):
- [ ] Implement repository methods
- [ ] Update sync methods
- [ ] Test CRUD operations
- [ ] Test sync integration

### Phase 5 (Sync):
- [ ] Update sync service
- [ ] Test POST sync
- [ ] Test GET sync
- [ ] Verify conflict resolution

### Phase 6 (Provider):
- [ ] Update EventsProvider
- [ ] Remove "coming soon" dialogs
- [ ] Test provider methods
- [ ] Verify state management

### Phase 7 (UI):
- [ ] Create species helper
- [ ] Update birth event form
- [ ] Create aborted pregnancy form
- [ ] Update events screen
- [ ] Test UI flows

### Phase 8 (Localization):
- [ ] Update English keys
- [ ] Update Swahili keys
- [ ] Regenerate localization
- [ ] Test translations

### Phase 9 (Constants):
- [ ] Update EventLogTypes
- [ ] Test constants
- [ ] Verify references

### Phase 10 (Testing):
- [ ] Test database migration
- [ ] Test sync flow
- [ ] Test forms
- [ ] Test UI
- [ ] Test offline mode
- [ ] Test error handling

---

## 📝 Notes

1. **Database Version:** Increment from 14 → 15
2. **Table Names:** Use camelCase in Drift (matches backend)
3. **Column Names:** Use camelCase (matches backend)
4. **Sync Payload:** Backend expects `birthEvents` and `abortedPregnancies` in logs
5. **API Endpoints:** Backend uses `/birth-events` and `/aborted-pregnancies`
6. **Reference Data:** Filter by `livestockTypeId` (null = generic, applies to all)

---

**End of Phased Implementation Plan**

