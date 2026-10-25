import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../theme/save_card_sheet_theme.dart';

class SaveCardSheetContent extends StatelessWidget {
  const SaveCardSheetContent({
    super.key,
    required this.monthDropdown,
    required this.yearDropdown,
    required this.onSave,
    this.isSaving = false,
    this.errorMessage,
  });

  final Widget monthDropdown;
  final Widget yearDropdown;
  final VoidCallback onSave;
  final bool isSaving;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SaveCardSheetTheme.radius),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        SaveCardSheetTheme.horizontalPadding,
        SaveCardSheetTheme.topPadding,
        SaveCardSheetTheme.horizontalPadding,
        MediaQuery.viewInsetsOf(context).bottom +
            SaveCardSheetTheme.bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SaveCardSheetHeader(),
            const SizedBox(height: SaveCardSheetTheme.headerToTitleGap),
            const Text('save card', style: SaveCardSheetTheme.title),
            const SizedBox(height: SaveCardSheetTheme.titleToDescriptionGap),
            const Text(
              'confirm expiration date',
              style: SaveCardSheetTheme.fieldText,
            ),
            const SizedBox(height: SaveCardSheetTheme.descriptionToFieldsGap),
            Row(
              children: [
                Expanded(child: monthDropdown),
                const SizedBox(width: SaveCardSheetTheme.fieldsGap),
                Expanded(child: yearDropdown),
              ],
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: SaveCardSheetTheme.fieldText.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: SaveCardSheetTheme.fieldsToButtonGap),
            SizedBox(
              width: double.infinity,
              height: SaveCardSheetTheme.buttonHeight,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SaveCardSheetTheme.primary,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'save card',
                        style: SaveCardSheetTheme.buttonText,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveCardSheetHeader extends StatelessWidget {
  const _SaveCardSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: SaveCardSheetTheme.headerSize,
          height: SaveCardSheetTheme.headerSize,
          // The SVG includes the 4px outer ring around its 48px core.
          child: OverflowBox(
            minWidth: SaveCardSheetTheme.featuredIconSize,
            maxWidth: SaveCardSheetTheme.featuredIconSize,
            minHeight: SaveCardSheetTheme.featuredIconSize,
            maxHeight: SaveCardSheetTheme.featuredIconSize,
            child: SvgPicture.asset('assets/icons/Featured icon.svg'),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: SaveCardSheetTheme.closeIconSize,
          height: SaveCardSheetTheme.closeIconSize,
          child: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: SaveCardSheetTheme.closeIconSize,
              height: SaveCardSheetTheme.closeIconSize,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: SvgPicture.asset(AssetConstant.blackRoundedCrossSVG),
          ),
        ),
      ],
    );
  }
}

class SaveCardExpiryDropdown extends StatelessWidget {
  const SaveCardExpiryDropdown({
    super.key,
    required this.valueListenable,
    required this.items,
    required this.onChanged,
  });

  final ValueListenable<int> valueListenable;
  final List<DropdownItem<int>> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SaveCardSheetTheme.fieldHeight,
      child: LayoutBuilder(
        builder: (context, constraints) => DropdownButton2<int>(
          isExpanded: true,
          underline: const SizedBox.shrink(),
          valueListenable: valueListenable,
          items: items,
          onChanged: onChanged,
          style: SaveCardSheetTheme.fieldText,
          buttonStyleData: ButtonStyleData(
            // A concrete width prevents the package adding menu padding to
            // the selected label, keeping both insets at exactly 16px.
            width: constraints.maxWidth,
            height: SaveCardSheetTheme.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: SaveCardSheetTheme.fieldHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: SaveCardSheetTheme.fieldBackground,
              borderRadius: BorderRadius.circular(
                SaveCardSheetTheme.fieldRadius,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset('assets/icons/down_blu.svg'),
          ),
        ),
      ),
    );
  }
}
