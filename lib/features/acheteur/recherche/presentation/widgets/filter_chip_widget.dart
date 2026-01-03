import 'package:flutter/material.dart';

/// Chip personnalisé pour afficher un filtre actif
class FilterChipWidget extends StatelessWidget {
  final String label;
  final String? value;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final IconData? icon;
  final Color? color;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.value,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).primaryColor;

    return InputChip(
      label: Text(
        value != null ? '$label: $value' : label,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : chipColor,
            )
          : null,
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onDelete,
      deleteIcon: onDelete != null
          ? Icon(
              Icons.close,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            )
          : null,
      backgroundColor: Colors.white,
      selectedColor: chipColor,
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withAlpha((0.5 * 255).round()),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isSelected ? 2 : 0,
      pressElevation: 4,
    );
  }
}

/// Rangée horizontale de chips de filtres
class FilterChipsRow extends StatelessWidget {
  final List<FilterChipData> filters;
  final void Function(String filterKey)? onRemoveFilter;
  final VoidCallback? onClearAll;

  const FilterChipsRow({
    super.key,
    required this.filters,
    this.onRemoveFilter,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                return FilterChipWidget(
                  label: filter.label,
                  value: filter.value,
                  isSelected: true,
                  icon: filter.icon,
                  onDelete: onRemoveFilter != null
                      ? () => onRemoveFilter!(filter.key)
                      : null,
                );
              },
            ),
          ),
          if (onClearAll != null && filters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Effacer',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modèle de données pour un chip de filtre
class FilterChipData {
  final String key;
  final String label;
  final String? value;
  final IconData? icon;

  const FilterChipData({
    required this.key,
    required this.label,
    this.value,
    this.icon,
  });
}

/// Chips pour une catégorie de filtres
class FilterCategoryChips extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?>? onSelected;
  final bool multiSelect;
  final Set<String>? selectedOptions;

  const FilterCategoryChips({
    super.key,
    required this.title,
    required this.options,
    this.selectedOption,
    this.onSelected,
    this.multiSelect = false,
    this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = multiSelect
                ? selectedOptions?.contains(option) ?? false
                : selectedOption == option;

            return FilterChipWidget(
              label: option,
              isSelected: isSelected,
              onTap: () {
                if (isSelected && !multiSelect) {
                  onSelected?.call(null);
                } else {
                  onSelected?.call(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Options de tri sous forme de chips
class SortOptionChips extends StatelessWidget {
  final String currentSort;
  final List<SortOptionData> options;
  final ValueChanged<String>? onSortChanged;

  const SortOptionChips({
    super.key,
    required this.currentSort,
    required this.options,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChipWidget(
                label: option.label,
                icon: option.icon,
                isSelected: currentSort == option.value,
                onTap: () => onSortChanged?.call(option.value),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Modèle pour une option de tri
class SortOptionData {
  final String value;
  final String label;
  final IconData? icon;

  const SortOptionData({
    required this.value,
    required this.label,
    this.icon,
  });
}
