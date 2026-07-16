import 'package:flutter/material.dart';
import 'package:my_resturant/core/l10n/messages_ku.dart';
import 'package:my_resturant/core/l10n/messages_ar.dart';
import 'package:my_resturant/core/l10n/messages_en.dart';

class Tr {
  static final Map<String, Map<String, String>> _data = {
    'ku': ku,
    'ar': ar,
    'en': en,
  };

  static String get(String key, Locale locale) =>
      _data[locale.languageCode]?[key] ?? _data['en']?[key] ?? key;
}
