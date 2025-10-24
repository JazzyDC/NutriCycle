import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'inventory_screen.dart';
import 'batch_history.dart';
import 'processing_navigation_screen.dart'; // Import for ProcessingStatusScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isConnected = false;
  bool _isScanning = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildDashboardScreen(),
      const ProcessingStatusScreen(), // Linked to ProcessingStatusScreen
      BatchHistoryScreen(),
      const SettingsScreen(),
    ];
  }

  Widget _buildDashboardScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'NutriCycle Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFF0B440E),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isConnected ? Icons.wifi : Icons.wifi_off,
                            color: const Color(0xFF0B440E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isConnected ? 'Connected' : 'Not Connected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              color: Color(0xFF0B440E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isConnected
                            ? 'Connected to NutriCycle machine.'
                            : 'Connect to a NutriCycle machine to get started.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Color(0xFF0B440E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleConnectToMachine,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B440E),
                          side: const BorderSide(
                            color: Color(0xFF0B440E),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 35),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Text(
                          _isConnected ? 'Disconnect' : 'Connect to Machine',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
       
         
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real-time Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2D2D2D),
                    ),
                    children: [
                      TextSpan(
                        text: 'Current Status: ',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      TextSpan(
                        text: 'Animal Feed Processing',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 16),
                _buildStatusRow(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF1B5E20),
                  label: 'Preparation',
                  time: '10:30 AM',
                  isCompleted: true,
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF1B5E20),
                  label: 'Recognition',
                  time: '10:30 AM',
                  isCompleted: true,
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF1B5E20),
                  label: 'Classification',
                  time: '10:30 AM',
                  isCompleted: true,
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.radio_button_checked,
                  iconColor: const Color(0xFF1B5E20),
                  label: 'Sorting',
                  time: 'In progress',
                  isActive: true,
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.radio_button_unchecked,
                  iconColor: Colors.grey,
                  label: 'Processing',
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.radio_button_unchecked,
                  iconColor: Colors.grey,
                  label: 'Completion',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '2 new updates',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF1B5E20),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: const Icon(Icons.pets,
                                  color: Color(0xFF1B5E20), size: 40),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Animal Feed',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '10 KG',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1B5E20),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 100,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: const Icon(Icons.eco_outlined,
                                  color: Color(0xFF1B5E20), size: 40),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Compost',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '10 KG',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1B5E20),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleConnectToMachine() async {
    if (_isConnected) {
      setState(() {
        _isConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from machine')),
      );
      return;
    }

    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required for WiFi scanning.')),
      );
      return;
    }

    if (await Permission.nearbyWifiDevices.isDenied) {
      final statusWifi = await Permission.nearbyWifiDevices.request();
      if (!statusWifi.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WiFi scanning permission required.')),
        );
        return;
      }
    }

    setState(() {
      _isScanning = true;
    });

    try {
      await WiFiScan.instance.startScan();
      final List<WiFiAccessPoint> results = await WiFiScan.instance.getScannedResults();

      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });

      if (results.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No WiFi networks found. Try again.')),
        );
        return;
      }

      await _showWiFiSelectionSheet(results);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
  }

  Future<void> _showWiFiSelectionSheet(List<WiFiAccessPoint> networks) async {
    final TextEditingController passwordController = TextEditingController();
    WiFiAccessPoint? selectedNetwork;

    await showModalBottomSheet<WiFiAccessPoint?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select NutriCycle Machine',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: networks.length,
                      itemBuilder: (context, index) {
                        final network = networks[index];
                        final signal = _getSignalBars(network.level);
                        return ListTile(
                          title: Text(network.ssid),
                          subtitle: Text('Signal: ${network.level} dBm'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(signal, (i) => const Icon(Icons.wifi, size: 16, color: Colors.grey)),
                          ),
                          selected: selectedNetwork?.ssid == network.ssid,
                          onTap: () => setSheetState(() {
                            selectedNetwork = network;
                          }),
                        );
                      },
                    ),
                  ),
                  if (selectedNetwork != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, selectedNetwork),
                      child: const Text('Connect'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedNetwork != null) {
      await _connectToWiFi(selectedNetwork!, passwordController.text);
    }
  }

  Future<void> _connectToWiFi(WiFiAccessPoint network, String password) async {
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('On iOS, connect via Settings manually.')),
        );
        return;
      }

      final bool connected = await WiFiForIoTPlugin.connect(
        network.ssid,
        password: password.isNotEmpty ? password : null,
        security: NetworkSecurity.WPA,
        withInternet: false,
      );

      if (!mounted) return;
      if (connected) {
        setState(() {
          _isConnected = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${network.ssid}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection failed. Check password.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  int _getSignalBars(int rssi) {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDisabled ? 0.1 : 0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFFEF8C2), size: 30),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFFEF8C2),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? time,
    bool isCompleted = false,
    bool isActive = false,
    bool isInactive = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isInactive
                      ? Colors.grey[400]
                      : isActive
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF4F7942),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? const Color(0xFF1B5E20)
                        : Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF1B5E20),
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined, size: 26),
                activeIcon: Icon(Icons.dashboard, size: 26),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_input_component_outlined, size: 26),
                activeIcon: Icon(Icons.settings_input_component, size: 26),
                label: 'Processing',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 26),
                activeIcon: Icon(Icons.history, size: 26),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, size: 26),
                activeIcon: Icon(Icons.settings, size: 26),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}