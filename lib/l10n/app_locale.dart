import 'dart:ui';

/// Follows the phone's language: Norwegian (nb/no/nn) -> nb, everything else
/// falls back to English.
Locale resolveAppLocale(Locale? device, Iterable<Locale> supported) {
  const norwegian = {'nb', 'no', 'nn'};
  if (device != null && norwegian.contains(device.languageCode)) {
    return const Locale('nb');
  }
  return const Locale('en');
}
