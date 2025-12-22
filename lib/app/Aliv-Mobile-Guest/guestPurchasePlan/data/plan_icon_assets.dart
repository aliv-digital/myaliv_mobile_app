import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../models/plan_model.dart';

class PlanIconAssets {
  // 🔥 এখানে তোমার project এর actual asset path / AssetConstant বসাবে
  static const String data = AssetConstant.wifiIconPNG;
  static const String talk = AssetConstant.phoneIconPNG;
  static const String sms = AssetConstant.smsIconPNG;
  static const String bonusData = AssetConstant.bonusDataIconPNG;
  static const String intl = AssetConstant.talkTextIconPNG;
  static const String mms = AssetConstant.mmsIconPNG;

  static String forType(PlanBenefitType type) {
    switch (type) {
      case PlanBenefitType.data:
        return data;
      case PlanBenefitType.talkMins:
        return talk;
      case PlanBenefitType.sms:
        return sms;
      case PlanBenefitType.bonusData:
        return bonusData;
      case PlanBenefitType.intlTalkText:
        return intl;
      case PlanBenefitType.mms:
        return mms;
    }
  }
}
