enum HomePlanBenefitType {
  data,
  talkMins,
  sms,
  bonusData,
  intlTalkText,
  mms,
}

class HomePlanBenefit {
  final HomePlanBenefitType type;
  final String label; // data / talk mins / sms ...
  final String value; // 1 / 30 / 300
  final String sub; // GB / local talk mins / local text ...

  const HomePlanBenefit({
    required this.type,
    required this.label,
    required this.value,
    required this.sub,
  });
}

class HomePlanModel {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String description; // expanded text
  final List<HomePlanBenefit> benefits; // scrollable row

  const HomePlanModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.description,
    required this.benefits,
  });
}
