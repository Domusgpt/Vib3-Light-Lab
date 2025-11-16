import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/visualizer_state.dart';
import '../models/preset_model.dart';

/// Visualizer View Widget
/// WebView wrapper for VIB34D visualizer with JavaScript bridge
class VisualizerView extends StatefulWidget {
  final VisualizerState state;
  final String? baseUrl;

  const VisualizerView({
    Key? key,
    required this.state,
    this.baseUrl,
  }) : super(key: key);

  @override
  State<VisualizerView> createState() => _VisualizerViewState();
}

class _VisualizerViewState extends State<VisualizerView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final baseUrl = widget.baseUrl ?? 'http://localhost:8080';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _injectInitialState();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse('$baseUrl/viewer.html'));
  }

  void _injectInitialState() {
    final params = widget.state.parameters;
    final system = widget.state.currentSystem.name;

    final jsCode = '''
      (function() {
        if (window.portalEngine) {
          // Set system
          window.portalEngine.switchSystem('$system');

          // Set parameters
          const params = ${_paramsToJson(params)};
          Object.keys(params).forEach(key => {
            if (window.updateParameter) {
              window.updateParameter(key, params[key]);
            }
          });

          // Set interactivity
          if (window.portalEngine.interactivityState) {
            window.portalEngine.interactivityState.mouse = ${widget.state.mouseReactive};
            window.portalEngine.interactivityState.tilt = ${widget.state.deviceTilt};
            window.portalEngine.interactivityState.audio = ${widget.state.audioReactive};
            window.portalEngine.interactivityState.enhanced = ${widget.state.enhancedFX};
            window.portalEngine.interactivityState.accentTwin = ${widget.state.accentTwin};
          }
        }
      })();
    ''';

    _controller.runJavaScript(jsCode);
  }

  String _paramsToJson(params) {
    return '''{
      "rot4dXW": ${params.rot4dXW},
      "rot4dYW": ${params.rot4dYW},
      "rot4dZW": ${params.rot4dZW},
      "gridDensity": ${params.gridDensity},
      "morphFactor": ${params.morphFactor},
      "chaos": ${params.chaos},
      "speed": ${params.speed},
      "hue": ${params.hue},
      "intensity": ${params.intensity},
      "saturation": ${params.saturation},
      "geometry": ${params.geometry}
    }''';
  }

  void _handleJavaScriptMessage(String message) {
    debugPrint('Message from WebView: $message');
    // Handle messages from JavaScript (e.g., audio data, errors, etc.)
  }

  void updateParameter(String paramName, double value) {
    final jsCode = '''
      if (window.updateParameter) {
        window.updateParameter('$paramName', $value);
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  void switchSystem(VisualizerSystem system) {
    final jsCode = '''
      if (window.switchSystem) {
        window.switchSystem('${system.name}');
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  void toggleInteractivity(String type, bool enabled) {
    final jsCode = '''
      if (window.portalEngine && window.portalEngine.toggleInteractivity) {
        window.portalEngine.toggleInteractivity('$type');
      }
    ''';
    _controller.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing Portal Engine...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
