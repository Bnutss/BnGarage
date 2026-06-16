class MileageUtils {
  static String format(int mileage, [String langCode = 'ru']) {
    String kmLabel;
    String thousandLabel;
    if (langCode == 'uz') {
      kmLabel = 'km';
      thousandLabel = 'ming $kmLabel';
    } else if (langCode == 'en') {
      kmLabel = 'km';
      thousandLabel = 'k $kmLabel';
    } else {
      kmLabel = 'км';
      thousandLabel = 'тыс. $kmLabel';
    }

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
