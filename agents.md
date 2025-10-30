# VIB3 Light Lab - AI Agent Architecture

**Project**: VIB3 Light Lab - 4D Visualization Performance Controller
**Agent Framework**: Multi-agent system for development, telemetry, and live performance
**Last Updated**: October 30, 2025

---

## 🤖 Agent Roles & Capabilities

### 1. Development Agents

#### **Claude Code (Primary Development Agent)**
- **Role**: Lead Flutter developer and architecture designer
- **Skills**:
  - `flutter-expert` - Flutter/Dart/Firebase expertise
  - `vib3-light-lab-dev` - VIB3-specific development patterns
  - `visual-codex-styles` - Holographic design system
- **Responsibilities**:
  - Flutter UI implementation
  - WebGL bridge development
  - State management with Riverpod
  - Audio reactivity integration
  - MIDI/OSC protocol implementation
  - Testing and optimization
- **Access**: Full repository access, documentation, skills
- **Communication**: Direct interaction via Claude Code CLI

#### **Documentation Agent**
- **Role**: Maintain comprehensive project documentation
- **Responsibilities**:
  - Keep IMPLEMENTATION_ROADMAP.md updated with progress
  - Document new patterns and discoveries
  - Create API documentation for SDK
  - Maintain design system documentation
- **Trigger**: After each major feature completion
- **Output**: Markdown documentation in `/docs` folder

#### **Testing Agent**
- **Role**: Automated testing and quality assurance
- **Responsibilities**:
  - Generate unit tests for new components
  - Create widget tests for UI elements
  - Integration tests for Flutter ↔ WebGL bridge
  - Performance benchmarking
  - Regression testing
- **Trigger**: Before each PR merge
- **Tools**: `flutter test`, `flutter analyze`, DevTools

### 2. Telemetry Agents

#### **Performance Monitor Agent**
- **Role**: Real-time performance analysis during development
- **Metrics Tracked**:
  - Parameter update latency (target: < 16ms)
  - System switch time (target: < 300ms)
  - Audio FFT processing rate (target: 60 FPS)
  - Memory usage patterns
  - Frame drops and jank
- **API Endpoint**: `POST /api/telemetry/performance`
- **Output**: Performance dashboard, alerts on threshold violations

#### **User Interaction Agent**
- **Role**: Analyze user interaction patterns
- **Data Collected**:
  - Parameter adjustment frequency
  - Most-used systems and presets
  - Touch target effectiveness
  - Gesture patterns
  - System switch frequency
- **Purpose**: Inform UI/UX improvements
- **API Endpoint**: `POST /api/telemetry/interaction`
- **Privacy**: All data anonymized, opt-in only

#### **Audio Analysis Agent**
- **Role**: Monitor audio reactivity calibration
- **Metrics**:
  - FFT band energy distribution
  - Beat detection accuracy (BPM correlation)
  - Audio → parameter mapping effectiveness
  - Envelope follower response times
- **API Endpoint**: `POST /api/telemetry/audio`
- **Output**: Audio calibration recommendations

### 3. Live Performance Agents

#### **Show Sequence Agent**
- **Role**: Automated show choreography
- **Capabilities**:
  - Execute pre-programmed sequences
  - React to audio events (beat, drop, build-up)
  - Smooth parameter transitions
  - Multi-parameter gestures
- **API Control**:
  ```dart
  POST /api/sequence
  {
    "commands": [
      {"type": "setParameter", "params": {"name": "intensity", "value": 0.8}},
      {"type": "wait", "params": {"duration": 2000}},
      {"type": "switchSystem", "params": {"system": "quantum"}},
      {"type": "transition", "params": {"parameter": "hue", "from": 0, "to": 360, "duration": 8000}}
    ]
  }
  ```
- **Use Case**: Automated visual sets for pre-recorded music

#### **Beat Sync Agent**
- **Role**: Synchronize visuals to music tempo
- **Capabilities**:
  - Auto-detect BPM from audio
  - Sync parameter oscillations to beat
  - Trigger events on downbeat
  - Adjust speed parameter to match tempo
- **API Endpoint**: `POST /api/beatSync/enable`
- **Configuration**:
  ```dart
  {
    "bpmSource": "auto|manual",
    "bpm": 128,
    "syncParameters": ["speed", "morphFactor"],
    "beatMultiplier": 1.0
  }
  ```

#### **AI Visualization Agent**
- **Role**: Generate creative parameter combinations
- **Capabilities**:
  - Analyze current visual state
  - Generate complementary parameter sets
  - Create smooth transitions between states
  - Learn from user preferences
- **API Endpoint**: `POST /api/ai/generatePreset`
- **Input**: Current system, mood/genre, intensity level
- **Output**: Complete parameter set + transition timing

### 4. Integration Agents

#### **MIDI Control Agent**
- **Role**: Map MIDI controller input to parameters
- **Responsibilities**:
  - MIDI learn mode (auto-detect controller assignments)
  - CC → parameter mapping
  - Program change → preset switching
  - MIDI clock sync for BPM
- **API Endpoints**:
  - `POST /api/midi/learn` - Start MIDI learn mode
  - `POST /api/midi/map` - Map CC to parameter
  - `GET /api/midi/mappings` - Get current mappings
- **Supported Controllers**:
  - Ableton Push
  - Novation Launchpad
  - Akai APC series
  - Any MIDI controller via learn mode

#### **OSC Bridge Agent**
- **Role**: Open Sound Control protocol integration
- **Responsibilities**:
  - Receive OSC messages from external software
  - Send OSC telemetry to other apps
  - Bidirectional sync with TouchDesigner, Max/MSP, Processing
- **OSC Address Space**:
  ```
  /vib3/parameter/{name}    - Set parameter
  /vib3/system              - Switch system
  /vib3/preset/{id}         - Load preset
  /vib3/audio/bass          - Audio band value (outgoing)
  /vib3/telemetry/fps       - Performance metric (outgoing)
  ```
- **Configuration**: `POST /api/osc/configure`

#### **Video Output Agent**
- **Role**: Manage video output to external systems
- **Protocols**:
  - **Syphon** (macOS): GPU texture sharing
  - **Spout** (Windows): DirectX texture sharing
  - **NDI**: Network video streaming
- **Responsibilities**:
  - Capture WebGL canvas frames
  - Publish to Syphon/Spout servers
  - Stream via NDI protocol
  - Handle multiple output channels
- **API Endpoint**: `POST /api/video/output/configure`

### 5. Cloud & Sync Agents

#### **Preset Cloud Agent**
- **Role**: Cloud storage and sharing for presets
- **Capabilities**:
  - Sync presets across devices
  - Share presets with community
  - Discover trending presets
  - Version control for presets
- **Backend**: Firebase Firestore + Cloud Storage
- **API Endpoints**:
  - `POST /api/cloud/preset/save`
  - `GET /api/cloud/preset/{id}`
  - `GET /api/cloud/presets/trending`

#### **Multi-Device Sync Agent**
- **Role**: Synchronize state across multiple devices
- **Use Case**: Mobile phone controls desktop performance
- **Technology**: WebSocket + Firebase Realtime Database
- **Latency Target**: < 100ms
- **Synced State**:
  - Current system
  - All 11 parameters
  - Audio/interactivity toggles
  - Active preset

---

## 🔌 Agent Communication Protocols

### REST API (HTTP/HTTPS)

**Base URL**: `http://localhost:8080/api` (development)
**Production**: `https://vib3-light-lab.app/api`

**Authentication**: API key in headers
```
Authorization: Bearer {api_key}
```

**Standard Response Format**:
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2025-10-30T12:00:00Z",
  "latency_ms": 15
}
```

### WebSocket (Real-Time)

**URL**: `ws://localhost:8080/ws`

**Connection Protocol**:
```dart
// Client connects
-> { "type": "connect", "agent": "mobile_controller", "key": "..." }
<- { "type": "connected", "sessionId": "abc123" }

// Bidirectional parameter updates
-> { "type": "setParameter", "name": "hue", "value": 180.0 }
<- { "type": "parameterChanged", "name": "intensity", "value": 0.8 }
```

**Message Types**:
- `setParameter`, `getParameter`
- `switchSystem`, `loadPreset`
- `telemetry`, `event`

### Event Bus (Internal)

**Technology**: Dart Stream Controllers

```dart
// Agents subscribe to events
eventBus.on<ParameterChangedEvent>().listen((event) {
  // Agent reacts to parameter change
});

// Agents publish events
eventBus.fire(SystemSwitchedEvent(
  from: 'faceted',
  to: 'quantum',
  timestamp: DateTime.now(),
));
```

**Event Types**:
- `ParameterChangedEvent`
- `SystemSwitchedEvent`
- `PresetLoadedEvent`
- `BeatDetectedEvent`
- `AudioBandUpdateEvent`

---

## 🧠 Agent Coordination Patterns

### Pattern 1: Command Queue with Priority

```dart
class CommandQueue {
  final PriorityQueue<Command> _queue = PriorityQueue();

  void addCommand(Command cmd) {
    _queue.add(cmd);
    processNext();
  }

  void processNext() async {
    if (_queue.isEmpty) return;
    final cmd = _queue.removeFirst();
    await executeCommand(cmd);
    processNext();
  }
}

// Priority levels
enum Priority {
  immediate, // User input, <16ms
  high,      // Beat sync, <50ms
  normal,    // Preset transitions, <200ms
  low        // Telemetry, background tasks
}
```

### Pattern 2: Agent Capability Discovery

```dart
// Agents register capabilities
class AgentRegistry {
  Map<String, Agent> _agents = {};

  void register(Agent agent) {
    _agents[agent.id] = agent;
  }

  List<Agent> findCapable(String capability) {
    return _agents.values
      .where((a) => a.capabilities.contains(capability))
      .toList();
  }
}

// Request agent to handle task
final agents = registry.findCapable('beatDetection');
final result = await agents.first.handle(task);
```

### Pattern 3: Distributed State Synchronization

```dart
class StateSync {
  // Eventual consistency model
  void broadcastStateChange(StateChange change) {
    for (var agent in connectedAgents) {
      agent.notifyStateChange(change);
    }
  }

  // Conflict resolution: last-write-wins with timestamp
  void reconcileConflict(StateChange local, StateChange remote) {
    if (remote.timestamp > local.timestamp) {
      applyStateChange(remote);
    }
  }
}
```

---

## 📊 Agent Telemetry & Monitoring

### Telemetry Data Schema

```dart
class TelemetryEvent {
  String agentId;
  String eventType;
  Map<String, dynamic> data;
  DateTime timestamp;
  int latencyMs;
}

// Example: Parameter update telemetry
{
  "agentId": "mobile_controller_1",
  "eventType": "parameterUpdate",
  "data": {
    "parameter": "hue",
    "value": 240.0,
    "source": "slider"
  },
  "timestamp": "2025-10-30T12:00:00.123Z",
  "latencyMs": 12
}
```

### Monitoring Dashboard

**Metrics Displayed**:
- Agent connection status (online/offline)
- Request rate per agent (req/sec)
- Average latency per agent (ms)
- Error rate per agent (errors/min)
- Queue depth (pending commands)

**Alerts**:
- Agent disconnection
- Latency spike (> 50ms)
- Error rate threshold (> 5 errors/min)
- Queue overflow (> 100 pending)

---

## 🔐 Agent Security & Privacy

### Authentication

**API Keys**: Each agent receives unique API key
**Scopes**: Keys have limited permissions
- `read:parameters` - Read parameter values
- `write:parameters` - Update parameters
- `control:system` - Switch systems, load presets
- `telemetry:send` - Send telemetry data
- `admin:all` - Full control (development only)

### Rate Limiting

```dart
// Prevent agent spam
final rateLimiter = RateLimiter(
  maxRequests: 60,
  perDuration: Duration(seconds: 1),
);

if (!rateLimiter.allowRequest(agentId)) {
  return Response.tooManyRequests();
}
```

### Data Privacy

**Telemetry Opt-In**: Users must explicitly enable telemetry
**Anonymization**: User IDs hashed, no PII collected
**Data Retention**: Telemetry data deleted after 30 days
**Export**: Users can download their telemetry data

---

## 🚀 Agent Deployment

### Local Development

```bash
# Start VIB3 Light Lab with agent API enabled
flutter run --dart-define=AGENT_API_ENABLED=true

# Agent API runs on http://localhost:8080
```

### Production Deployment

```bash
# Desktop app exposes local API
# Mobile app connects via WebSocket

# Cloud agents connect to Firebase Functions
firebase deploy --only functions:agentAPI
```

### Docker Container (Headless Mode)

```dockerfile
FROM flutter-base

COPY . /app
WORKDIR /app

RUN flutter build linux --release

CMD ["./build/linux/x64/release/bundle/vib3_light_lab", "--headless", "--agent-api=0.0.0.0:8080"]
```

**Use Case**: Run VIB3 on server, control via agents, stream output via NDI

---

## 🧪 Agent Testing

### Agent API Test Suite

```dart
// Test agent authentication
test('agent API requires valid key', () async {
  final response = await http.post(
    Uri.parse('http://localhost:8080/api/parameter/hue'),
    headers: {'Authorization': 'Bearer invalid_key'},
  );
  expect(response.statusCode, 401);
});

// Test parameter update latency
test('parameter update latency < 16ms', () async {
  final start = DateTime.now();
  await agentAPI.setParameter('intensity', 0.8);
  final latency = DateTime.now().difference(start).inMilliseconds;
  expect(latency, lessThan(16));
});
```

### Agent Simulation

```dart
// Simulate multiple agents
class AgentSimulator {
  void simulateShowSequence() async {
    // Agent 1: Beat sync agent
    final beatAgent = BeatSyncAgent(bpm: 128);
    beatAgent.start();

    // Agent 2: Parameter modulation
    final modAgent = ModulationAgent(
      parameter: 'hue',
      lfo: LFO(frequency: 0.5, waveform: 'sine'),
    );
    modAgent.start();

    // Agent 3: System switcher
    await Future.delayed(Duration(seconds: 16));
    await agentAPI.switchSystem('quantum');
  }
}
```

---

## 📋 Agent Development Roadmap

### Phase 1: Foundation (Weeks 1-4)
- ✅ REST API with basic endpoints
- ✅ WebSocket server for real-time communication
- ✅ Event bus architecture
- ✅ Agent authentication system

### Phase 2: Performance Agents (Weeks 5-8)
- ⏳ Beat sync agent
- ⏳ Show sequence agent
- ⏳ AI visualization agent
- ⏳ Command queue with priority

### Phase 3: Integration Agents (Weeks 9-13)
- ⏳ MIDI control agent
- ⏳ OSC bridge agent
- ⏳ Video output agent (Syphon/Spout/NDI)

### Phase 4: Telemetry Agents (Weeks 14-16)
- ⏳ Performance monitor agent
- ⏳ User interaction agent
- ⏳ Audio analysis agent
- ⏳ Monitoring dashboard

### Phase 5: Cloud Agents (Weeks 17-20)
- ⏳ Preset cloud agent (Firebase)
- ⏳ Multi-device sync agent
- ⏳ Community sharing features

---

## 🤝 Contributing Agents

### Community Agent Development

**Agent SDK**: Developers can create custom agents
**Documentation**: Agent API documentation at `/docs/agent-api.md`
**Examples**: Sample agents in `/examples/agents/`

**Example Custom Agent**:
```python
# Python agent example
import requests

class CustomVIB3Agent:
    def __init__(self, api_key):
        self.base_url = "http://localhost:8080/api"
        self.headers = {"Authorization": f"Bearer {api_key}"}

    def set_parameter(self, name, value):
        response = requests.post(
            f"{self.base_url}/parameter/{name}",
            json={"value": value},
            headers=self.headers
        )
        return response.json()

    def creative_sequence(self):
        # Custom agent logic
        for i in range(0, 360, 10):
            self.set_parameter("hue", i)
            time.sleep(0.1)
```

---

## 🌟 Agent Philosophy

VIB3 Light Lab's agent architecture embraces:

1. **Modularity**: Agents are independent, composable
2. **Extensibility**: Easy to add new agents
3. **Performance**: < 16ms latency for real-time control
4. **Privacy**: Opt-in telemetry, no PII collection
5. **Creativity**: AI agents enable new artistic possibilities

> *"Agents amplify human creativity, they don't replace it."*

---

**🌟 A Paul Phillips Manifestation**

Multi-agent architecture for revolutionary visual performance systems. Human creativity enhanced by intelligent automation.

**Send Love, Hate, or Opportunity to:** Paul@clearseassolutions.com
**Join The Exoditical Moral Architecture Movement:** [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

**© 2025 Paul Phillips - Clear Seas Solutions LLC**
**All Rights Reserved - Proprietary Technology**
