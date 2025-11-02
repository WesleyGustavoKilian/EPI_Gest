import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final String allItemsLabel;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.allItemsLabel = 'Todos',
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  void _toggleDropdown() {
    _overlayController.toggle();
  }

  void _closeDropdown() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  Widget _buildDropdownContent() {
    final theme = Theme.of(context);
    final tempSelected = List<String>.from(widget.selectedItems);

    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return Positioned(
          width: (context.findRenderObject() as RenderBox?)?.size.width ?? 300,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, 4),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.icon,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setDropdownState(() {
                                tempSelected.clear();
                              });
                            },
                            child: const Text('Limpar'),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              setDropdownState(() {
                                tempSelected.clear();
                                tempSelected.addAll(widget.items);
                              });
                            },
                            child: const Text('Todos'),
                          ),
                        ],
                      ),
                    ),

                    // Lista
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: widget.items.map((item) {
                          final isSelected = tempSelected.contains(item);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(item),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? value) {
                              setDropdownState(() {
                                if (value == true) {
                                  tempSelected.add(item);
                                } else {
                                  tempSelected.remove(item);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _closeDropdown,
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              widget.onChanged(tempSelected);
                              _closeDropdown();
                            },
                            child: Text(
                              'Aplicar (${tempSelected.length})',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDisplayText() {
    if (widget.selectedItems.isEmpty) {
      return widget.allItemsLabel;
    } else if (widget.selectedItems.length == 1) {
      return widget.selectedItems.first;
    } else if (widget.selectedItems.length == widget.items.length) {
      return widget.allItemsLabel;
    } else {
      return '${widget.selectedItems.length} selecionados';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [_buildDropdownContent()],
            ),
          );
        },
        child: InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: Icon(widget.icon),
              suffixIcon: Icon(
                _overlayController.isShowing
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            child: Text(
              _getDisplayText(),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
