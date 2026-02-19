import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../models/plan_model.dart';

class HomePlanIconAssets {
  // 🔥 এখানে তোমার project এর actual asset path / AssetConstant বসাবে
  static const String data = AssetConstant.wifiIconPNG;
  static const String talk = AssetConstant.phoneIconPNG;
  static const String sms = AssetConstant.smsIconPNG;
  static final String bonusData = AssetConstant.bonusDataIconSVG;
  static const String phone = AssetConstant.phoneCallIconSVG;//phoneIconPNG;//talkTextIconPNG;
  static const String mms = AssetConstant.mmsIconPNG;
  static const String usOrCanTalk = AssetConstant.talkTextIconSVG;


  static String forType(HomePlanBenefitType type) {
    switch (type) {
      case HomePlanBenefitType.data:
        return data;
      case HomePlanBenefitType.talkMins:
        return talk;
      case HomePlanBenefitType.sms:
        return sms;
      case HomePlanBenefitType.bonusData:
        return bonusData;
      case HomePlanBenefitType.intlTalkText:
        return usOrCanTalk;
      case HomePlanBenefitType.mms:
        return phone;
    }
  }
}
