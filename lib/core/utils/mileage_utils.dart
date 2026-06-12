class MileageUtils {
  static String format(int mileage, [String langCode = 'ru']) {
    final kmLabel = langCode == 'en' ? 'km' : 'км';
    final thousandLabel = langCode == 'en' ? 'k $kmLabel' : 'тыс. $kmLabel';

    if (mileage >= 1000) {
      final km = mileage / 1000;
      final formatted = km % 1 == 0
          ? km.toInt().toString()
          : km.toStringAsFixed(1);
      return '$formatted $thousandLabel';
    }
    return '$mileage $kmLabel';
  }
}
