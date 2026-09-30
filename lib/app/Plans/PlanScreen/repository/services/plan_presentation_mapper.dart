import 'package:myaliv_mobile_app/app/Plans/PlanScreen/data/plan_bucket_icons.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Resolves the display type for a plan bucket using keyword matching on the
/// lowercased [BasePlanBucketModel.bucketUnit] identifier, falling back to the
/// bucket name. Keyword matching tolerates minor backend naming variations
/// (e.g. `INS_Data` vs `INS_Data_MIFI`) without requiring an exhaustive list
/// of exact-string pairs.
class PlanPresentationMapper {
  const PlanPresentationMapper();

  BucketItemType bucketItemType(BasePlanBucketModel bucket) {
    final id = bucket.bucketUnit.trim().toLowerCase();
    final unit = bucket.unit.trim().toLowerCase();

    // WhatsApp / social-app data buckets
    if (id.contains('whatsapp')) return BucketItemType.whatsApp;

    // LDI (Long Distance International) — text unit → international SMS label
    if (id.contains('ldi')) {
      return unit == 'text' ? BucketItemType.internationalSMS : BucketItemType.call;
    }

    // Voice buckets — Text unit means on-net SMS (e.g. INS_Voice_Only_National + Text)
    if (id.contains('voice')) {
      return unit == 'text' ? BucketItemType.sms : BucketItemType.call;
    }

    // SMS / MMS — US/Canada and Nat-US variants are international
    if (id.contains('sms') || id.contains('mms')) {
      final isIntl = id.contains('us_canada') || id.contains('nat_us');
      return isIntl ? BucketItemType.internationalSMS : BucketItemType.sms;
    }

    // Data buckets — includes social-media app data (TikTok, Facebook)
    if (id.contains('data') || id.contains('tiktok') || id.contains('facebook')) {
      return BucketItemType.data;
    }

    return BucketItemType.call;
  }
}
