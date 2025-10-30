/// VIB3 Light Lab - Preset Management Provider
///
/// Manages saved engine state configurations (presets).
/// Handles loading, saving, and organizing presets.
///
/// © 2025 Paul Phillips - Clear Seas Solutions LLC

library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/engine_state.dart';
import 'engine_provider.dart';

/// Preset Storage Keys
class _PresetStorageKeys {
  static const String presetsList = 'vib3_presets_list';
  static const String presetPrefix = 'vib3_preset_';
}

/// Preset List Notifier - Manages list of saved presets
class PresetListNotifier extends StateNotifier<AsyncValue<List<Preset>>> {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  PresetListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadPresets();
  }

  /// Load presets from storage
  Future<void> _loadPresets() async {
    state = const AsyncValue.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_PresetStorageKeys.presetsList);

      if (presetsJson == null || presetsJson.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final presets = presetsJson
          .map((json) => Preset.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(presets);
      debugPrint('[PresetProvider] Loaded ${presets.length} presets');
    } catch (e, stack) {
      debugPrint('[PresetProvider] Error loading presets: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Save current engine state as preset
  Future<Preset?> saveCurrentState({
    required String name,
    String? description,
    List<String> tags = const [],
  }) async {
    try {
      final currentState = _ref.read(engineProvider);

      final preset = Preset.fromEngineState(
        id: _uuid.v4(),
        name: name,
        description: description,
        state: currentState,
        tags: tags,
      );

      await _savePreset(preset);

      debugPrint('[PresetProvider] Saved preset: $name');
      return preset;
    } catch (e) {
      debugPrint('[PresetProvider] Error saving preset: $e');
      return null;
    }
  }

  /// Save preset to storage
  Future<void> _savePreset(Preset preset) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current list
    final currentList = state.valueOrNull ?? [];
    final updatedList = [...currentList, preset];

    // Save preset data
    final presetsJson = updatedList.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_PresetStorageKeys.presetsList, presetsJson);

    // Update state
    state = AsyncValue.data(updatedList);
  }

  /// Load preset into engine
  Future<void> loadPreset(Preset preset) async {
    try {
      final notifier = _ref.read(engineProvider.notifier);

      // Switch system if different
      if (preset.state.currentSystem != _ref.read(currentSystemProvider)) {
        await notifier.switchSystem(preset.state.currentSystem);
      }

      // Update all parameters
      await notifier.updateParameters(preset.state.parameters);

      // Update toggles
      await notifier.toggleAudio(preset.state.audioEnabled);
      await notifier.toggleInteractivity(preset.state.interactivityEnabled);
      await notifier.toggleDeviceTilt(preset.state.deviceTiltEnabled);

      debugPrint('[PresetProvider] Loaded preset: ${preset.name}');
    } catch (e) {
      debugPrint('[PresetProvider] Error loading preset: $e');
    }
  }

  /// Delete preset
  Future<void> deletePreset(String presetId) async {
    try {
      final currentList = state.valueOrNull ?? [];
      final updatedList =
          currentList.where((p) => p.id != presetId).toList();

      final prefs = await SharedPreferences.getInstance();
      final presetsJson =
          updatedList.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_PresetStorageKeys.presetsList, presetsJson);

      state = AsyncValue.data(updatedList);

      debugPrint('[PresetProvider] Deleted preset: $presetId');
    } catch (e) {
      debugPrint('[PresetProvider] Error deleting preset: $e');
    }
  }

  /// Update preset
  Future<void> updatePreset(Preset preset) async {
    try {
      final currentList = state.valueOrNull ?? [];
      final index = currentList.indexWhere((p) => p.id == preset.id);

      if (index == -1) {
        debugPrint('[PresetProvider] Preset not found: ${preset.id}');
        return;
      }

      final updatedList = [...currentList];
      updatedList[index] = preset;

      final prefs = await SharedPreferences.getInstance();
      final presetsJson =
          updatedList.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_PresetStorageKeys.presetsList, presetsJson);

      state = AsyncValue.data(updatedList);

      debugPrint('[PresetProvider] Updated preset: ${preset.name}');
    } catch (e) {
      debugPrint('[PresetProvider] Error updating preset: $e');
    }
  }

  /// Clear all presets
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_PresetStorageKeys.presetsList);

      state = const AsyncValue.data([]);

      debugPrint('[PresetProvider] Cleared all presets');
    } catch (e) {
      debugPrint('[PresetProvider] Error clearing presets: $e');
    }
  }

  /// Refresh presets from storage
  Future<void> refresh() async {
    await _loadPresets();
  }
}

/// Preset List Provider
///
/// Usage:
/// ```dart
/// // Watch presets
/// final presetsAsync = ref.watch(presetListProvider);
/// presetsAsync.when(
///   data: (presets) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
///
/// // Save preset
/// await ref.read(presetListProvider.notifier).saveCurrentState(
///   name: 'My Preset',
///   description: 'Cool visualization',
///   tags: ['quantum', 'blue'],
/// );
///
/// // Load preset
/// await ref.read(presetListProvider.notifier).loadPreset(preset);
/// ```
final presetListProvider =
    StateNotifierProvider<PresetListNotifier, AsyncValue<List<Preset>>>((ref) {
  return PresetListNotifier(ref);
});

/// Filtered Presets Provider - Filter presets by tag
///
/// Usage:
/// ```dart
/// final quantumPresets = ref.watch(filteredPresetsProvider('quantum'));
/// ```
final filteredPresetsProvider =
    Provider.family<List<Preset>, String>((ref, tag) {
  final presetsAsync = ref.watch(presetListProvider);

  return presetsAsync.maybeWhen(
    data: (presets) => presets.where((p) => p.tags.contains(tag)).toList(),
    orElse: () => [],
  );
});

/// Preset Count Provider - Total number of saved presets
final presetCountProvider = Provider<int>((ref) {
  final presetsAsync = ref.watch(presetListProvider);

  return presetsAsync.maybeWhen(
    data: (presets) => presets.length,
    orElse: () => 0,
  );
});

/// Recent Presets Provider - Most recently created/modified presets
///
/// Usage:
/// ```dart
/// final recentPresets = ref.watch(recentPresetsProvider(5));
/// ```
final recentPresetsProvider = Provider.family<List<Preset>, int>((ref, count) {
  final presetsAsync = ref.watch(presetListProvider);

  return presetsAsync.maybeWhen(
    data: (presets) => presets.take(count).toList(),
    orElse: () => [],
  );
});
