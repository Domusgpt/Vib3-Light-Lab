import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/visualizer_state.dart';
import '../models/preset_model.dart';
import '../widgets/preset_card.dart';
import '../widgets/collapsible_panel.dart';
import '../services/preset_manager.dart';

/// Preset Panel Screen
/// Preset library, save/load functionality, and show planner
class PresetPanel extends StatefulWidget {
  const PresetPanel({Key? key}) : super(key: key);

  @override
  State<PresetPanel> createState() => _PresetPanelState();
}

class _PresetPanelState extends State<PresetPanel> {
  final PresetManager _presetManager = PresetManager();
  List<PresetModel> _presets = [];
  String _searchQuery = '';
  String _filterSystem = 'all';

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await _presetManager.loadPresets();
    setState(() {
      _presets = presets;
    });
  }

  List<PresetModel> get _filteredPresets {
    return _presets.where((preset) {
      final matchesSearch = preset.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          preset.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSystem =
          _filterSystem == 'all' || preset.system.name == _filterSystem;
      return matchesSearch && matchesSystem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisualizerState>(
      builder: (context, state, child) {
        return Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _SearchBar(
                    onChanged: (query) => setState(() => _searchQuery = query),
                  ),
                  const SizedBox(height: 8),
                  _SystemFilter(
                    selectedSystem: _filterSystem,
                    onChanged: (system) =>
                        setState(() => _filterSystem = system),
                  ),
                ],
              ),
            ),

            // Save Current Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showSaveDialog(context, state),
                icon: const Icon(Icons.save),
                label: const Text('Save Current State'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Preset List
            Expanded(
              child: _filteredPresets.isEmpty
                  ? _EmptyState(searchQuery: _searchQuery)
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredPresets.length,
                      itemBuilder: (context, index) {
                        final preset = _filteredPresets[index];
                        final isActive = state.activePreset?.id == preset.id;

                        return PresetCard(
                          preset: preset,
                          isActive: isActive,
                          onTap: () {
                            state.loadPreset(preset);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Loaded preset: ${preset.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onEdit: () => _showEditDialog(context, preset),
                          onDelete: () => _deletePreset(context, preset),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context, VisualizerState state) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Preset Name',
                hintText: 'My Awesome Preset',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe this preset...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final preset = PresetModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descController.text,
                  system: state.currentSystem,
                  parameters: state.parameters,
                );

                _presetManager.savePreset(preset);
                _loadPresets();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved preset: ${preset.name}'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        _presetManager.deletePreset(preset.id);
                        _loadPresets();
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PresetModel preset) {
    final nameController = TextEditingController(text: preset.name);
    final descController = TextEditingController(text: preset.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Preset Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = preset.copyWith(
                name: nameController.text,
                description: descController.text,
                modifiedAt: DateTime.now(),
              );

              _presetManager.updatePreset(updated);
              _loadPresets();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preset updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePreset(BuildContext context, PresetModel preset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _presetManager.deletePreset(preset.id);
              _loadPresets();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted preset: ${preset.name}'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      _presetManager.savePreset(preset);
                      _loadPresets();
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search presets...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
    );
  }
}

/// System Filter Widget
class _SystemFilter extends StatelessWidget {
  final String selectedSystem;
  final ValueChanged<String> onChanged;

  const _SystemFilter({
    required this.selectedSystem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedSystem == 'all',
            onTap: () => onChanged('all'),
          ),
          ...VisualizerSystem.values.map((system) {
            return _FilterChip(
              label: '${system.icon} ${system.displayName}',
              isSelected: selectedSystem == system.name,
              onTap: () => onChanged(system.name),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Empty State Widget
class _EmptyState extends StatelessWidget {
  final String searchQuery;

  const _EmptyState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.library_add : Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No presets yet'
                : 'No presets found for "$searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Create your first preset using the save button'
                : 'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
