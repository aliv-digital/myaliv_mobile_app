# 🔍 Debug Plan Categorization Issue

## Current Issue

Plans exist in API response but are NOT showing in the view:
- API returns plans with `Frequency: "S"` and `Frequency: "B"` (not in enum)
- API returns plans with various `PlanType` values ("A", "S")
- Plans load successfully but don't appear in UI

## Root Cause Analysis

The issue is likely one of these:

1. **Unknown Frequencies**: API returns `Frequency: "S"` and `Frequency: "B"` which aren't in our `PlanFrequency` enum (only has D, W, M)
2. **Missing PlanGroup**: Addon plans (Type "A") need a `PlanGroup` to be categorized
3. **Unknown categories**: Plans are being categorized as `unknown` and not displayed

## Debug Logging Added ✅

I've added comprehensive logging to `plan_categorizer_service.dart` to help diagnose the issue:

### What Gets Logged

For **EVERY** plan being categorized, you'll see:

```
🔍 CATEGORIZING PLAN:
   PlanID: 12345
   PlanName: Example Plan Name
   PlanType: A → PlanType.addon
   Frequency: S → null (not in enum!)
   PlanGroup: roaming → PlanGroup.roaming
   PaymentOption: postpay → PaymentOption.postpay
      → Addon: Roaming + PostPay = PostpaidRoaming
   ✅ Category: postpaidRoaming
```

### Key Information

- **Raw API values** (e.g., "A", "S", "B")
- **Parsed enum values** (e.g., `PlanType.addon` or `null` if not recognized)
- **Categorization logic** (which rules matched)
- **Final category** (e.g., `postpaidRoaming`, `unknown`)

---

## How to Debug

### Step 1: Run the App

```bash
flutter run
```

### Step 2: Open Plans Screen

1. Login as PostPay user
2. Navigate to Plans screen
3. Switch between tabs

### Step 3: Watch the Console

Look for the debug output in your IDE console or terminal. You'll see categorization logs for every plan.

### Step 4: Identify the Problem

#### Example: Plans marked as UNKNOWN

```
🔍 CATEGORIZING PLAN:
   PlanID: 30937
   PlanName: 3GB Bonus Roaming Data
   PlanType: A → PlanType.addon
   Frequency: S → null
   PlanGroup:  → null
   PaymentOption: postpay → PaymentOption.postpay
      → Addon: NO PlanGroup found - marking as UNKNOWN
   ✅ Category: unknown
```

**Problem**: PlanGroup is missing or empty!
**Solution**: Check API response, add PlanGroup to enum if needed

#### Example: Unknown Frequency (but OK for addons)

```
🔍 CATEGORIZING PLAN:
   PlanID: 12345
   PlanName: Roaming Data Add-on
   PlanType: A → PlanType.addon
   Frequency: S → null (not recognized)
   PlanGroup: roaming → PlanGroup.roaming
   PaymentOption: postpay → PaymentOption.postpay
      → Addon: Roaming + PostPay = PostpaidRoaming
   ✅ Category: postpaidRoaming
```

**Status**: ✅ This is OK! Addon plans don't use frequency for categorization

#### Example: Unknown Frequency (problem for primary plans)

```
🔍 CATEGORIZING PLAN:
   PlanID: 67890
   PlanName: Daily Plan
   PlanType: P → PlanType.primary
   Frequency: S → null
   PlanGroup:  → null
   PaymentOption: prepay → PaymentOption.prepay
      → Primary: NO frequency found - marking as UNKNOWN
   ✅ Category: unknown
```

**Problem**: Primary plans NEED a valid frequency (D, W, or M)
**Solution**: Add "S" to PlanFrequency enum if it's a valid frequency type

---

## Common Issues and Fixes

### Issue 1: Addon Plans with Unknown PlanGroup

**Symptoms**:
```
PlanType: A → PlanType.addon
PlanGroup:  → null
✅ Category: unknown
```

**Possible Causes**:
1. API doesn't send `PlanGroup` field
2. PlanGroup value not in enum (e.g., `"special"`, `"bonus"`)

**Check**: Look at raw API response to see what `PlanGroup` value is sent

**Fix Options**:
- Add new value to `PlanGroup` enum
- Update categorizer to handle empty PlanGroup for certain addon types

### Issue 2: Unknown Frequency for Addon Plans (Not a problem!)

**Symptoms**:
```
PlanType: A → PlanType.addon
Frequency: S → null
PlanGroup: roaming → PlanGroup.roaming
✅ Category: postpaidRoaming
```

**Status**: ✅ This is EXPECTED and CORRECT
- Addon plans are categorized by `PlanGroup`, not `Frequency`
- `Frequency: "S"` or `"B"` being null is fine for addons

### Issue 3: Unknown Frequency for Primary Plans

**Symptoms**:
```
PlanType: P → PlanType.primary
Frequency: S → null
✅ Category: unknown
```

**Problem**: Primary plans NEED a valid frequency
**Fix**: Add "S" and "B" to `PlanFrequency` enum if they're valid frequency types

### Issue 4: Special Plans Not Categorized

**Symptoms**:
```
PlanType: S → PlanType.special
Frequency: M → PlanFrequency.monthly
PlanGroup:  → null
      → Special: No matching criteria - marking as UNKNOWN
✅ Category: unknown
```

**Problem**: Special plans need roaming keywords or liberty global group
**Fix**: Update `_categorizeSpecialPlan()` to handle more cases

---

## What to Look For in Console

### 1. Count Plans by Category

After seeing all the logs, count how many plans fall into each category:

- ✅ `dailyPlans`: X
- ✅ `weeklyPlans`: X
- ✅ `monthlyPlans`: X
- ✅ `roaming`: X
- ✅ `postpaidRoaming`: X
- ❌ `unknown`: X ← **This is the problem!**

### 2. Identify Patterns

Look for common patterns in `unknown` plans:
- Do they all have `Frequency: "S"`?
- Do they all have empty `PlanGroup`?
- Are they all `PlanType: "A"`?

### 3. Check Raw API Values

For plans marked `unknown`, note the raw values:
```
PlanType: A
Frequency: S
PlanGroup: <WHAT IS THIS?>
PaymentOption: postpay
```

Share these values with me so I can update the categorizer!

---

## Next Steps

### Immediate: Collect Debug Data

1. **Run the app**
2. **Open Plans screen**
3. **Copy console output**
4. **Share with me**

Look for:
- How many plans are marked as `unknown`?
- What are the raw values for those plans?
- What PlanGroup values exist in the API?

### After Diagnosis: Fix the Categorizer

Based on the debug output, I can:

1. **Add missing PlanGroup values** to enum
2. **Add missing Frequency values** to enum (if needed)
3. **Update categorization logic** to handle edge cases
4. **Improve special plan detection**

---

## Example Console Output

Here's what you should see:

```
🔍 CATEGORIZING PLAN:
   PlanID: 30937
   PlanName: 3GB Bonus Roaming Data US/Can
   PlanType: S → PlanType.special
   Frequency: M → PlanFrequency.monthly
   PlanGroup: roaming → PlanGroup.roaming
   PaymentOption: postpay → PaymentOption.postpay
      → Special: checking roaming-related...
         Name contains "roam": true
         Desc contains "roam": false
         PlanGroup=roaming: true
      → Special: Roaming + PostPay = PostpaidRoaming
   ✅ Category: postpaidRoaming

🔍 CATEGORIZING PLAN:
   PlanID: 12345
   PlanName: Data Add-on 1GB
   PlanType: A → PlanType.addon
   Frequency: S → null
   PlanGroup: roaming → PlanGroup.roaming
   PaymentOption: postpay → PaymentOption.postpay
      → Addon: Roaming + PostPay = PostpaidRoaming
   ✅ Category: postpaidRoaming

🔍 CATEGORIZING PLAN:
   PlanID: 67890
   PlanName: Unknown Addon
   PlanType: A → PlanType.addon
   Frequency: B → null
   PlanGroup:  → null
   PaymentOption: postpay → PaymentOption.postpay
      → Addon: NO PlanGroup found - marking as UNKNOWN
   ✅ Category: unknown
```

In this example:
- First 2 plans: ✅ Categorized correctly
- Last plan: ❌ Marked as `unknown` because `PlanGroup` is empty

---

## Quick Reference: Categorization Rules

### Primary Plans (Type = P)
- **MiFi**: Has `PlanGroup = "mifi (30 day)"`
- **Daily**: `Frequency = "D"`
- **Weekly**: `Frequency = "W"`
- **Monthly**: `Frequency = "M"`
- **Unknown**: Missing frequency or unrecognized

### Addon Plans (Type = A)
- **Roaming**: `PlanGroup = "roaming"` + prepay
- **PostpaidRoaming**: `PlanGroup = "roaming"` + postpay
- **RoamEasy**: `PlanGroup = "roameasy"`
- **LibertyGlobal**: `PlanGroup = "liberty global"`
- **Unknown**: Missing or unrecognized PlanGroup

### Special Plans (Type = S)
- **PostpaidRoaming**: Contains "roam" in name/desc + postpay
- **LibertyGlobal**: `PlanGroup = "liberty global"`
- **Unknown**: Doesn't match criteria

---

## Remove Debug Logging Later

Once we fix the issue, I'll remove all the `print` statements from the categorizer. They're only for debugging right now.

---

## Summary

✅ **Debug logging is active**
✅ **Run the app and check console**
✅ **Share debug output with me**
✅ **I'll fix the categorizer based on the data**

Ready to debug! 🚀
