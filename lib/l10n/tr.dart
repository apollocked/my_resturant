import 'package:flutter/material.dart';

class Tr {
  static const _data = <String, Map<String, String>>{
    'ku': {
      'settings': 'ڕێکخستنەکان',
      'theme': 'ڕوانگە',
      'language': 'زمان',
      'light': 'ڕوون',
      'dark': 'تاریک',
      'kurdish': 'کوردی',
      'arabic': 'عەرەبی',
      'english': 'ئینگلیزی',
      'cancel': 'ڕەتکردنەوە',
      'cart': 'داواکاری',
      'menu': 'مینیو',
      'kitchen': 'چێشتخانە',
      'profile': 'پڕۆفایل',
    },
    'ar': {
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'kurdish': 'الكردية',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'cancel': 'إلغاء',
      'cart': 'السلة',
      'menu': 'القائمة',
      'kitchen': 'المطبخ',
      'profile': 'الملف الشخصي',
    },
    'en': {
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'kurdish': 'Kurdish',
      'arabic': 'Arabic',
      'english': 'English',
      'cancel': 'Cancel',
      'cart': 'Cart',
      'menu': 'Menu',
      'kitchen': 'Kitchen',
      'profile': 'Profile',
    },
  };

  static String get(String key, Locale locale) =>
      _data[locale.languageCode]?[key] ?? _data['en']?[key] ?? key;
}
