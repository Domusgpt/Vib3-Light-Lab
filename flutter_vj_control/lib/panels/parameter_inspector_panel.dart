import 'package:flutter/material.dart';
import '../widgets/parameter_slider.dart';
import '../core/parameter_bank.dart';
import '../core/workspace_manager.dart';

/// Parameter Inspector Panel - shows parameters for active effect/system
class ParameterInspectorPanel extends StatefulWidget {
  const ParameterInspectorPanel({super.key});

  @override
  State<ParameterInspectorPanel> createState() => _ParameterInspectorPanelState();
}

class _ParameterInspectorPanelState extends State<ParameterInspectorPanel> {
  final ParameterBank _parameterBank = ParameterBank();
  final WorkspaceManager _workspaceManager = WorkspaceManager();

  ParameterCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Category selector
          _buildCategorySelector(),
          // Parameter list
          Expanded(
            child: _buildParameterList(),
          ),
          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white70),
          const SizedBox(width: 12),
          const Text(
            'Parameters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            _workspaceManager.activeSystem.toUpperCase(),
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build category selector
  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryChip(null, 'All', Icons.dashboard),
          const SizedBox(width: 8),
          ..._parameterBank.getCategories().map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(
                category,
                category.displayName,
                category.icon,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build category chip
  Widget _buildCategoryChip(
    ParameterCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.purple, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build parameter list
  Widget _buildParameterList() {
    final parameters = _selectedCategory == null
        ? _parameterBank.getAllParameters()
        : _parameterBank.getByCategory(_selectedCategory!);

    return ListenableBuilder(
      listenable: _workspaceManager,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: parameters.length,
          itemBuilder: (context, index) {
            final param = parameters[index];
            final value = _workspaceManager.getParameterValue(param.id);

            return ParameterSlider(
              parameter: param,
              value: value,
              onChanged: (newValue) {
                _workspaceManager.updateParameter(param.id, newValue);
              },
            );
          },
        );
      },
    );
  }

  /// Build quick actions
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedCategory == null) {
                  _workspaceManager.randomizeAllParameters();
                } else {
                  _workspaceManager.randomizeCategory(_selectedCategory!);
                }
              },
              icon: const Icon(Icons.shuffle),
              label: Text(_selectedCategory == null
                  ? 'Randomize All'
                  : 'Randomize ${_selectedCategory!.displayName}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _workspaceManager.resetAllParameters();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
