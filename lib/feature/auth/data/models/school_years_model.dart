// make a model for diffrent year lists it just stores the lists in another place to declutter the other pages
class SchoolYearsModel {
  static List<String> getSchoolYears() {
    return ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'];
  }

  static List<String> getFamilies() {
    return ['كي جي', 'ابتدائي', 'اعدادي', 'ثانوي', 'جامعة'];
  }

  static const Map<String, List<String>> allYears = {
    'كي جي': ['كى جي 1', 'كى جي 2'],
    'ابتدائي': [
      'اولي ابتدائي',
      'تانيه ابتدائي',
      'ثالثة ابتدائي',
      'رابعة ابتدائي',
      'خامسة ابتدائي',
      'سادسة ابتدائي',
    ],
    'اعدادي': ['اولي اعدادي', 'تانيه اعدادي', 'ثالثة اعدادي'],
    'ثانوي': ['اولي ثانوي', 'تانيه ثانوي', 'ثالثة ثانوي'],
    'جامعة': [
      'اولي جامعة',
      'تانيه جامعة',
      'ثالثة جامعة',
      'رابعة جامعة',
      'خامسة جامعة',
      'سادسة جامعة',
    ],
  };
}
