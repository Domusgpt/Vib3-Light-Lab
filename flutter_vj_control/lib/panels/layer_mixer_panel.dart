import 'package:flutter/material.dart';
import '../core/workspace_manager.dart';

/// Layer Mixer Panel - system compositing and blending
class LayerMixerPanel extends StatefulWidget {
  const LayerMixerPanel({super.key});

  @override
  State<LayerMixerPanel> createState() => _LayerMixerPanelState();
}

class _LayerMixerPanelState extends State<LayerMixerPanel> {
  final WorkspaceManager _workspaceManager = WorkspaceManager();

  final Map<String, LayerState> _layers = {
    'faceted': LayerState(
      id: 'faceted',
      name: 'Faceted',
      emoji: '🔷',
      color: Colors.blue,
    ),
    'quantum': LayerState(
      id: 'quantum',
      name: 'Quantum',
      emoji: '🌌',
      color: Colors.purple,
    ),
    'holographic': LayerState(
      id: 'holographic',
      name: 'Holographic',
      emoji: '✨',
      color: Colors.pink,
    ),
    'polychora': LayerState(
      id: 'polychora',
      name: 'Polychora',
      emoji: '🔮',
      color: Colors.cyan,
    ),
  };

  double _crossfaderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Layer strips
          Expanded(
            child: _buildLayerStrips(),
          ),
          // Crossfader
          _buildCrossfader(),
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
      child: const Row(
        children: [
          Icon(Icons.layers, color: Colors.white70),
          SizedBox(width: 12),
          Text(
            'Layer Mixer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build layer strips
  Widget _buildLayerStrips() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: _layers.values.map((layer) {
        return _buildLayerStrip(layer);
      }).toList(),
    );
  }

  /// Build individual layer strip
  Widget _buildLayerStrip(LayerState layer) {
    final isActive = _workspaceManager.activeSystem == layer.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? layer.color.withOpacity(0.2)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? layer.color.withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer header
          Row(
            children: [
              // Emoji and name
              Text(
                layer.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  layer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Solo button
              IconButton(
                icon: Icon(
                  layer.solo ? Icons.star : Icons.star_border,
                  color: layer.solo ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    layer.solo = !layer.solo;
                  });
                },
                tooltip: 'Solo',
              ),
              // Mute button
              IconButton(
                icon: Icon(
                  layer.muted ? Icons.volume_off : Icons.volume_up,
                  color: layer.muted ? Colors.red : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    layer.muted = !layer.muted;
                  });
                },
                tooltip: 'Mute',
              ),
              // Select button
              IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: isActive ? layer.color : Colors.white30,
                ),
                onPressed: () {
                  _workspaceManager.switchSystem(layer.id);
                },
                tooltip: 'Activate',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Opacity slider
          Row(
            children: [
              const Icon(Icons.opacity, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                'Opacity',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    activeTrackColor: layer.color,
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: layer.opacity,
                    onChanged: (value) {
                      setState(() {
                        layer.opacity = value;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '${(layer.opacity * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Blend mode selector
          Row(
            children: [
              const Icon(Icons.blur_on, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                'Blend',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: ['Normal', 'Add', 'Multiply', 'Screen'].map((mode) {
                    final isSelected = layer.blendMode == mode;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          layer.blendMode = mode;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? layer.color.withOpacity(0.6)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mode,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build crossfader
  Widget _buildCrossfader() {
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
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Layer A',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    activeTrackColor: Colors.purple,
                    inactiveTrackColor: Colors.blue,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _crossfaderValue,
                    onChanged: (value) {
                      setState(() {
                        _crossfaderValue = value;
                      });
                    },
                  ),
                ),
              ),
              const Text(
                'Layer B',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Crossfade: ${(_crossfaderValue * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Layer state
class LayerState {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  double opacity;
  String blendMode;
  bool solo;
  bool muted;

  LayerState({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.opacity = 1.0,
    this.blendMode = 'Normal',
    this.solo = false,
    this.muted = false,
  });
}
