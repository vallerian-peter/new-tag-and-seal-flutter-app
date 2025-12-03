/// Helper functions for species-aware UI labels and terminology

/// Get parity label based on species
String getParityLabel(String speciesName) {
  return speciesName.toLowerCase() == 'pig' 
    ? 'Parity/Litter Number' 
    : 'Parity/Lactation Number';
}

/// Get last birth label
String getLastBirthLabel(String speciesName) {
  return speciesName.toLowerCase() == 'pig' 
    ? 'Date of Last Farrowing' 
    : 'Date of Last Calving';
}

/// Get birth event name
String getBirthEventName(String speciesName) {
  return speciesName.toLowerCase() == 'pig' ? 'Farrowing' : 'Calving';
}

/// Get offspring name
String getOffspringName(String speciesName) {
  return speciesName.toLowerCase() == 'pig' ? 'Piglet' : 'Calf';
}

/// Get event type based on species name
String getBirthEventType(String speciesName) {
  return speciesName.toLowerCase() == 'pig' ? 'farrowing' : 'calving';
}

/// Check if species is pig
bool isPig(String speciesName) {
  return speciesName.toLowerCase() == 'pig';
}

