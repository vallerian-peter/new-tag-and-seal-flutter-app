class EventLogTypes {
  static const feeding = 'feeding';
  static const insemination = 'insemination';
  static const pregnancy = 'pregnancy';
  static const deworming = 'deworming';
  static const weightChange = 'weightChange';
  static const disposal = 'disposal';
  static const disposalTransfer = disposal;
  static const calving = 'calving';
  static const farrowing = 'farrowing'; // NEW: For pig births
  static const abortedPregnancy = 'abortedPregnancy'; // NEW: For pig aborted pregnancies
  static const vaccination = 'vaccination';
  static const dryoff = 'dryoff';
  static const medication = 'medication';
  static const milking = 'milking';
  static const transfer = 'transfer';

  /// Get the birth event type based on species name
  /// Returns 'farrowing' for pigs, 'calving' for others
  static String getBirthEventType(String speciesName) {
    return speciesName.toLowerCase() == 'pig' ? farrowing : calving;
  }

  /// Get all birth-related event types
  static List<String> get birthEventTypes => [calving, farrowing];
}



