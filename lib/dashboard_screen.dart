import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'inventory_screen.dart';
import 'batch_history.dart';
import 'processing_navigation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectedNetworkName = '';

  final Map<String, dynamic> _machineStatus = {
    'currentStage': 'Waiting for machine...',
    'lastSync': '—',
    'currentTask': '—',
    'stages': {
      'Preparation': {'completed': false, 'time': ''},
      'Recognition': {'completed': false, 'time': ''},
      'Sorting': {'completed': false, 'time': ''},
      'Grinding': {'completed': false, 'time': ''},
      'Depositing': {'completed': false, 'time': ''},
      'Completion': {'completed': false, 'time': ''},
    },
  };

  // Real values — start at zero or empty
  double _animalFeedKg = 0.0;
  double _animalFeedMax = 3.0;
  double _compostKg = 0.0;
  double _compostMax = 2.5;
  double _totalProcessedFeed = 0.0;
  double _totalCompost = 0.0;
  double _wasteDiverted = 0.0;

  // Live status from Processing screen
  String _currentProcessingTask = 'Idle';
  String _currentProcessingMode = 'None';

  // Track full process completion
  bool _isProcessCompleted = false;

  late final List<Widget> _screens;

  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  MqttServerClient? _mqttClient;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final String _targetSsid = 'NutriCycle-1';

  @override
  void initState() {
    super.initState();

    _screens = [
      Container(), // Placeholder — real dashboard inserted in build()
      ProcessingNavigationScreen(
        onStatusUpdate: (task, mode) {
          if (!mounted) return;

          setState(() {
            _currentProcessingTask = task;
            _currentProcessingMode = mode;

            if (task == 'Completion' && mode == 'Compost Process') {
              _isProcessCompleted = true;
            }
          });
        },
      ),
      const InventoryScreen(),
      const BatchHistoryScreen(),
      const SettingsScreen(),
    ];

    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _disconnectMqtt();
    super.dispose();
  }

  // --------------------------- CONNECTION & MQTT ---------------------------
  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final isWifi = result.contains(ConnectivityResult.wifi);
    if (!isWifi) return _setDisconnected();

    final rawName = await _networkInfo.getWifiName();
    final currentSsid = rawName?.replaceAll('"', '').trim() ?? '';

    if (currentSsid != _targetSsid) return _setDisconnected();

    setState(() {
      _isConnected = true;
      _connectedNetworkName = currentSsid;
      _isConnecting = false;
    });

    if (_mqttClient == null || _mqttClient!.connectionStatus!.state != MqttConnectionState.connected) {
      _connectMqtt();
    }
  }

  void _setDisconnected() {
    setState(() {
      _isConnected = false;
      _connectedNetworkName = '';
      _isConnecting = false;
      _machineStatus['currentStage'] = 'Waiting for machine...';
      _machineStatus['lastSync'] = '—';
      _machineStatus['currentTask'] = '—';
      _machineStatus['stages'].forEach((key, _) {
        _machineStatus['stages'][key] = {'completed': false, 'time': ''};
      });
    });
    _disconnectMqtt();
  }

  Future<void> _connectMqtt() async {
    if (_mqttClient?.connectionStatus?.state == MqttConnectionState.connected) return;

    _mqttClient = MqttServerClient('192.168.4.1', 'nutricycle_app_${DateTime.now().millisecondsSinceEpoch}')
      ..port = 1883
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..onDisconnected = _onMqttDisconnected
      ..onConnected = _onMqttConnected;

    final connMessage = MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    _mqttClient!.connectionMessage = connMessage;

    try {
      await _mqttClient!.connect();
    } catch (e) {
      debugPrint('MQTT Failed: $e');
      _setDisconnected();
    }
  }

  void _onMqttConnected() {
    debugPrint('MQTT Connected');
    _mqttClient!.subscribe('nutricycle/machine/status', MqttQos.atLeastOnce);
    _mqttClient!.updates!.listen(_onMqttMessage);
  }

  void _onMqttDisconnected() => debugPrint('MQTT Disconnected');

  void _disconnectMqtt() {
    _mqttClient?.disconnect();
    _mqttClient = null;
  }

  void _onMqttMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final payload = MqttPublishPayload.bytesToStringAsString((event[0].payload as MqttPublishMessage).payload.message);
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        setState(() {
          _machineStatus['currentStage'] = data['currentStage'] ?? 'Idle';
          _machineStatus['lastSync'] = data['lastSync'] ?? '—'; // You can update this from MQTT if available
          _machineStatus['currentTask'] = data['currentTask'] ?? '—';

          final stages = data['stages'] as Map<String, dynamic>? ?? {};
          _machineStatus['stages'].forEach((key, _) {
            final stage = stages[key];
            if (stage != null) {
              _machineStatus['stages'][key] = {
                'completed': stage['completed'] == true,
                'time': stage['time']?.toString() ?? '',
              };
            }
          });
        });
      }
    } catch (e) {
      debugPrint('Invalid payload: $e');
    }
  }

  // --------------------------- UI HELPERS ---------------------------
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: Color(0xFF666666))),
        const SizedBox(width: 8),
        if (label == 'Status:' && value == 'Online')
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle)),
        if (label == 'Status:' && value == 'Online') const SizedBox(width: 6),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: value == 'Online' ? const Color(0xFF1B5E20) : Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildStageIndicator(String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? const Color(0xFF1B5E20) : Colors.transparent,
            border: Border.all(color: completed ? const Color(0xFF1B5E20) : Colors.grey[400]!, width: 2),
          ),
          child: completed ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      ],
    );
  }

  Widget _buildInventoryBin(String label, double current, double max) {
    final percentage = (current / max).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: ArcProgressPainter(percentage: percentage, strokeWidth: 12, activeColor: const Color(0xFF1B5E20), inactiveColor: Colors.grey[300]!)),
        ),
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Color(0xFF1B5E20))),
        const SizedBox(height: 4),
        Text('${current.toStringAsFixed(1)} kg / ${max.toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 11, fontFamily: 'Poppins', color: Colors.grey[600])),
      ],
    );
  }

  // --------------------------- DASHBOARD CONTENT ---------------------------
  Widget _buildDashboardContent() {
    return Container(
      color: const Color(0xFFFEF8C2),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    const Text(
                      'NutriCycle Dashboard',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Poppins', color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 24),

                    // MAIN CARD – TOTAL PROCESSED FEED
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Total of Processed Feed Meal',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Color(0xFFFEF8C2)),
                                ),
                              ),
                              const Icon(Icons.info_outline, color: Color(0xFFFEF8C2), size: 20),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${_totalProcessedFeed.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFFEF8C2),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Image.asset(
                                'assets/iconchicken.png',
                                width: 80,
                                height: 80,
                                color: const Color(0xFFFEF8C2),
                                colorBlendMode: BlendMode.modulate,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('${_totalCompost.toStringAsFixed(1)} kg',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Poppins', color: Color(0xFF1B5E20))),
                              const SizedBox(height: 6),
                              const Text('total of\nprocessed compost',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1B5E20), height: 1.3)),
                            ],
                          ),
                        ),
                        Container(width: 2, height: 70, color: const Color(0xFF1B5E20).withOpacity(0.3)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('${_wasteDiverted.toStringAsFixed(1)} kg',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Poppins', color: Color(0xFF1B5E20))),
                              const SizedBox(height: 6),
                              const Text('total of\nwaste diverted',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1B5E20), height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Device Status Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wifi, color: _isConnected ? const Color(0xFF1B5E20) : Colors.grey, size: 24),
                            const SizedBox(width: 8),
                            Text(_isConnected ? _connectedNetworkName : 'Not Connected',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _isConnected ? const Color(0xFF1B5E20) : Colors.grey[700], fontFamily: 'Poppins')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Status:', _isConnected ? 'Online' : 'Offline'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Last Sync:', _machineStatus['lastSync']),
                        const SizedBox(height: 8),
                        _buildInfoRow('Current Task:', _machineStatus['currentTask']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Status Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() => _currentIndex = 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Status: $_currentProcessingTask',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1B5E20)),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFF1B5E20), size: 24),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_currentProcessingMode != 'None')
                                Text(
                                  _currentProcessingMode,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStageIndicator('Preparation', true),
                                  _buildStageIndicator('Recognition', _currentProcessingTask != 'Idle'),
                                  _buildStageIndicator('Sorting', _currentProcessingTask == 'Sorting' || _currentProcessingTask == 'Vermicasting' || _currentProcessingTask == 'Completion'),
                                  _buildStageIndicator('Vermicasting', _currentProcessingTask == 'Vermicasting' || _currentProcessingTask == 'Completion'),
                                  _buildStageIndicator('Depositing', false),
                                  _buildStageIndicator('Completion', _isProcessCompleted),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Preparation', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                  Text('Recognition', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                  Text('Sorting', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                  Text('Vermicasting', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                  Text('Depositing', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                  Text('Completion', style: TextStyle(fontSize: 9, fontFamily: 'Poppins')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inventory Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _currentIndex = 2),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1B5E20))),
                                  Icon(Icons.chevron_right, color: Color(0xFF1B5E20), size: 24),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(child: _buildInventoryBin('Animal Feed Bin', _animalFeedKg, _animalFeedMax)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildInventoryBin('Compost Bin', _compostKg, _compostMax)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _screens[0] = _buildDashboardContent();

    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Bottom navigation and painters remain unchanged (same as previous version)
class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar> {
  final List<NavItem> _items = [
    NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    NavItem(icon: Icons.sync_outlined, activeIcon: Icons.sync, label: 'Processing'),
    NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Inventory'),
    NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'History'),
    NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / _items.length;

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.currentIndex * itemWidth,
            top: 0,
            child: Container(
              width: itemWidth,
              height: 45,
              child: CustomPaint(
                painter: CurvedBackgroundPainter(),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.currentIndex * itemWidth + (itemWidth / 2) - 35,
            top: -25,
            child: Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _items[widget.currentIndex].activeIcon,
                size: 30,
                color: const Color(0xFFFEF8C2),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: List.generate(_items.length, (index) {
                final isSelected = widget.currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isSelected)
                            Icon(
                              _items[index].icon,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                          if (!isSelected) const SizedBox(height: 4),
                          if (isSelected) const SizedBox(height: 28),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: isSelected ? const Color(0xFF1B5E20) : Colors.grey[400],
                            ),
                            child: Text(_items[index].label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CurvedBackgroundPainter extends CustomPainter {
  final Color color = const Color(0xFFFEF8C2);
  final double curveHeight = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.2 + curveHeight,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ArcProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;

  ArcProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    const totalSweepAngle = 2 * math.pi;

    final bgPaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, totalSweepAngle, false, bgPaint);

    final progressPaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, totalSweepAngle * percentage, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}