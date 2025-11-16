import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/preset_model.dart';

/// Preset Manager Service
/// Handles saving, loading, and managing presets
class PresetManager {
  static const String _storageKey = 'vib34d_presets';

  /// Load all presets from storage
  Future<List<PresetModel>> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = prefs.getString(_storageKey);

    if (presetsJson == null) {
      return _getDefaultPresets();
    }

    try {
      final List<dynamic> presetsList = json.decode(presetsJson);
      return presetsList
          .map((json) => PresetModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading presets: $e');
      return _getDefaultPresets();
    }
  }

  /// Save a preset
  Future<void> savePreset(PresetModel preset) async {
    final presets = await loadPresets();
    presets.add(preset);
    await _saveAllPresets(presets);
  }

  /// Update an existing preset
  Future<void> updatePreset(PresetModel preset) async {
    final presets = await loadPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);

    if (index != -1) {
      presets[index] = preset;
      await _saveAllPresets(presets);
    }
  }

  /// Delete a preset
  Future<void> deletePreset(String presetId) async {
    final presets = await loadPresets();
    presets.removeWhere((p) => p.id == presetId);
    await _saveAllPresets(presets);
  }

  /// Save all presets to storage
  Future<void> _saveAllPresets(List<PresetModel> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = json.encode(
      presets.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_storageKey, presetsJson);
  }

  /// Get default presets
  List<PresetModel> _getDefaultPresets() {
    return [
      PresetModel(
        id: 'default_1',
        name: 'Cyan Dreams',
        description: 'Smooth cyan rotations with medium chaos',
        system: VisualizerSystem.faceted,
        parameters: ParameterModel(
          hue: 180,
          intensity: 0.7,
          saturation: 0.9,
          gridDensity: 20,
          morphFactor: 1.2,
          chaos: 0.3,
          speed: 1.2,
          rot4dXW: 0.5,
          rot4dYW: -0.3,
          rot4dZW: 0.2,
        ),
      ),
      PresetModel(
        id: 'default_2',
        name: 'Purple Quantum',
        description: 'Complex quantum lattice in purple',
        system: VisualizerSystem.quantum,
        parameters: ParameterModel(
          hue: 280,
          intensity: 0.8,
          saturation: 0.85,
          gridDensity: 35,
          morphFactor: 1.5,
          chaos: 0.5,
          speed: 0.8,
          rot4dXW: -0.4,
          rot4dYW: 0.6,
          rot4dZW: -0.2,
        ),
      ),
      PresetModel(
        id: 'default_3',
        name: 'Pink Hologram',
        description: 'Audio-reactive pink holographic display',
        system: VisualizerSystem.holographic,
        parameters: ParameterModel(
          hue: 320,
          intensity: 0.9,
          saturation: 1.0,
          gridDensity: 25,
          morphFactor: 1.8,
          chaos: 0.4,
          speed: 1.5,
          rot4dXW: 0.3,
          rot4dYW: 0.3,
          rot4dZW: 0.3,
        ),
      ),
      PresetModel(
        id: 'default_4',
        name: '4D Tesseract',
        description: '4D polytope mathematics visualization',
        system: VisualizerSystem.polychora,
        parameters: ParameterModel(
          hue: 200,
          intensity: 0.6,
          saturation: 0.8,
          gridDensity: 15,
          morphFactor: 1.0,
          chaos: 0.2,
          speed: 1.0,
          rot4dXW: 1.0,
          rot4dYW: 1.0,
          rot4dZW: 1.0,
        ),
      ),
    ];
  }
}
