import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/visualizer_state.dart';
import 'screens/control_panel.dart';
import 'screens/audio_panel.dart';
import 'screens/preset_panel.dart';
import 'widgets/visualizer_view.dart';
import 'theme/vj_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (landscape for VJ work)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const VJControlApp());
}

class VJControlApp extends StatelessWidget {
  const VJControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisualizerState(),
      child: MaterialApp(
        title: 'VIB34D VJ Control',
        theme: VJTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPanelIndex = 0;
  bool _showVisualizer = true;
  bool _isFullscreen = false;

  final List<Widget> _panels = const [
    ControlPanel(),
    AudioPanel(),
    PresetPanel(),
  ];

  final List<String> _panelTitles = const [
    'Control Deck',
    'Audio Reactivity',
    'Preset Library',
  ];

  final List<IconData> _panelIcons = const [
    Icons.tune,
    Icons.graphic_eq,
    Icons.library_music,
  ];

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<VisualizerState>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: _isFullscreen
              ? null
              : AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.currentSystem.icon),
                      const SizedBox(width: 8),
                      const Text('VIB34D VJ Control'),
                    ],
                  ),
                  actions: [
                    // Visualizer toggle
                    IconButton(
                      icon: Icon(_showVisualizer
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() => _showVisualizer = !_showVisualizer),
                      tooltip: 'Toggle Visualizer',
                    ),
                    // Fullscreen toggle
                    IconButton(
                      icon: Icon(_isFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen),
                      onPressed: _toggleFullscreen,
                      tooltip: 'Toggle Fullscreen',
                    ),
                  ],
                ),
          body: isLandscape && _showVisualizer
              ? _buildLandscapeLayout(state)
              : _buildPortraitLayout(state),
          bottomNavigationBar: _isFullscreen
              ? null
              : _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildLandscapeLayout(VisualizerState state) {
    return Row(
      children: [
        // Visualizer (left side)
        Expanded(
          flex: 7,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: VisualizerView(state: state),
          ),
        ),
        // Control Panel (right side)
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                // Panel selector
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: List.generate(
                      _panels.length,
                      (index) => Expanded(
                        child: _PanelTab(
                          icon: _panelIcons[index],
                          label: _panelTitles[index],
                          isSelected: _selectedPanelIndex == index,
                          onTap: () => setState(() => _selectedPanelIndex = index),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Panel content
                Expanded(child: _panels[_selectedPanelIndex]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(VisualizerState state) {
    if (_showVisualizer) {
      return Column(
        children: [
          // Visualizer (top)
          Expanded(
            flex: 4,
            child: VisualizerView(state: state),
          ),
          // Control Panel (bottom)
          Expanded(
            flex: 6,
            child: _panels[_selectedPanelIndex],
          ),
        ],
      );
    } else {
      return _panels[_selectedPanelIndex];
    }
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedPanelIndex,
      onTap: (index) => setState(() => _selectedPanelIndex = index),
      items: List.generate(
        _panels.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(_panelIcons[index]),
          label: _panelTitles[index],
        ),
      ),
    );
  }
}

/// Panel Tab Widget for landscape mode
class _PanelTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PanelTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label.split(' ').first, // Show first word only
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
