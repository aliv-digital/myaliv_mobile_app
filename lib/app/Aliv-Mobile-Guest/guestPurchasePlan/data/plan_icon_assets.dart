import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../models/plan_model.dart';

class PlanIconAssets {
  // 🔥 এখানে তোমার project এর actual asset path / AssetConstant বসাবে
  static const String data = AssetConstant.wifiIconPNG;
  static const String talk = AssetConstant.phoneIconPNG;
  static const String sms = AssetConstant.smsIconPNG;
  static final String bonusData = AssetConstant.bonusDataIconSVG;
  static const String phone = AssetConstant.phoneCallIconSVG;//phoneIconPNG;//talkTextIconPNG;
  static const String mms = AssetConstant.mmsIconPNG;
  static const String usOrCanTalk = AssetConstant.talkTextIconSVG;


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
        return usOrCanTalk;
      case PlanBenefitType.mms:
        return phone;
    }
  }
}
