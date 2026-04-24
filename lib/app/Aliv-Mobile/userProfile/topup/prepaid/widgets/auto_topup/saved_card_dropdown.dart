import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'card_list_overlay.dart';
import 'dropdown_content_widgets.dart';

/// Dropdown widget for selecting saved credit cards.
/// Uses [SavedCardsCubit] to fetch and display cards from API.
class SavedCardDropdown extends StatefulWidget {
  final SavedCardModel? selectedCard;
  final ValueChanged<SavedCardModel?> onCardSelected;

  const SavedCardDropdown({
    super.key,
    required this.selectedCard,
    required this.onCardSelected,
  });

  @override
  State<SavedCardDropdown> createState() => _SavedCardDropdownState();
}

class _SavedCardDropdownState extends State<SavedCardDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedCardsCubit, SavedCardsState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: state.hasCards ? _toggleDropdown : _getEmptyTapHandler(state),
            child: DropdownContainer(
              child: Row(
                children: [
                  Expanded(child: _buildContent(state)),
                  _buildTrailingIcon(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, SavedCardsState state) {
    if (state.isSuccess && state.hasCards && widget.selectedCard == null) {
      widget.onCardSelected(state.cards.first);
    }
  }

  Widget _buildContent(SavedCardsState state) {
    if (state.isLoading) return const DropdownLoadingContent();
    if (state.hasError) return const DropdownErrorContent();
    if (state.isEmpty) return const DropdownEmptyContent();

    return DropdownSelectedCardContent(
      displayText: widget.selectedCard?.displayLabel ?? 'select a card',
    );
  }

  Widget _buildTrailingIcon(SavedCardsState state) {
    if (state.isLoading) return const SizedBox.shrink();

    if (state.hasError) {
      return GestureDetector(
        onTap: () => context.read<SavedCardsCubit>().refreshSavedCards(),
        child: const Icon(Icons.refresh, color: Color(0xFFE53935)),
      );
    }

    if (state.isEmpty) {
      return const Icon(Icons.credit_card_off, color: Color(0xFF707070));
    }

    return Icon(_isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down);
  }

  VoidCallback? _getEmptyTapHandler(SavedCardsState state) {
    if (state.hasError) {
      return () => context.read<SavedCardsCubit>().refreshSavedCards();
    }
    return null;
  }

  void _toggleDropdown() {
    _isOpen ? _removeOverlay() : _showOverlay();
  }

  void _showOverlay() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlay() {
    final cards = context.read<SavedCardsCubit>().state.cards;

    return OverlayEntry(
      builder: (ctx) => CardListOverlay(
        layerLink: _layerLink,
        cards: cards,
        selectedToken: widget.selectedCard?.token,
        onCardSelected: (card) {
          widget.onCardSelected(card);
          _removeOverlay();
        },
      ),
    );
  }
}
