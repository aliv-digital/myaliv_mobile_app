import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../models/plan_model.dart';

class PlanBucketIcons {

  static const String dataIcon = AssetConstant.wifiIconSVG;
  //static const String phoneIcon = AssetConstant.phoneIconSVG;
  static const String sms = AssetConstant.smsIconSVG;
  static final String whatsAppIcon = AssetConstant.bonusDataIconSVG;
  static const String phoneCallIcon = AssetConstant.phoneCallIconSVG;
  static const String messageIcon = AssetConstant.talkTextIconSVG;


  static String forType(BucketItemType type) {

    switch (type) {
      case BucketItemType.data:
        return dataIcon;
      case BucketItemType.call:
        return phoneCallIcon;
      case BucketItemType.sms:
        return sms;
      case BucketItemType.whatsApp:
        return whatsAppIcon;
      case BucketItemType.internationalSMS:
        return messageIcon;

    }
  }
}


enum BucketItemType {
  whatsApp,
  call,
  sms,
  internationalSMS,
  data
}
