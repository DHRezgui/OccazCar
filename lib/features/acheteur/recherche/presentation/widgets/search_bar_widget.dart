import 'package:flutter/material.dart';

/// Barre de recherche personnalisée
class SearchBarWidget extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final String hintText;
  final bool hasActiveFilters;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClear,
    this.hintText = 'Rechercher une voiture...',
    this.hasActiveFilters = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          if (controller?.text.isNotEmpty ?? false)
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),

          Container(
            height: 24,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: hasActiveFilters
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                  size: 24,
                ),
                onPressed: onFilterTap,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
                tooltip: 'Filtres avancés',
              ),
              if (hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barre de recherche avec suggestions
class SearchBarWithSuggestions extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final List<String> suggestions;
  final bool hasActiveFilters;

  const SearchBarWithSuggestions({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.suggestions = const [],
    this.hasActiveFilters = false,
  });

  @override
  State<SearchBarWithSuggestions> createState() => _SearchBarWithSuggestionsState();
}

class _SearchBarWithSuggestionsState extends State<SearchBarWithSuggestions> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = widget.suggestions
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();
      }
      _showSuggestions = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barre de recherche principale
        SearchBarWidget(
          controller: _controller,
          onChanged: (value) {
            _filterSuggestions(value);
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSubmitted,
          onFilterTap: widget.onFilterTap,
          onClear: () {
            setState(() {
              _filteredSuggestions = [];
              _showSuggestions = false;
            });
          },
          hasActiveFilters: widget.hasActiveFilters,
        ),

        // Liste de suggestions
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  leading: const Icon(Icons.history, size: 20),
                  title: Text(suggestion),
                  dense: true,
                  onTap: () {
                    _controller.text = suggestion;
                    widget.onSubmitted?.call(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
