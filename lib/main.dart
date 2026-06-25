import 'package:flutter/material.dart';
import 'package:v2ray_stk/services/preferences_service.dart';
import 'package:v2ray_stk/services/vpn_service.dart';
import 'dart:convert';
import 'dart:core';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V2RAY stk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SettingsPage(),
    const AdminWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'ادمین'),
        ],
      ),
    );
  }
}

// ========== صفحه خانه ==========
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VpnService _vpnService = VpnService();
  bool _isLoading = false;
  bool _isInitializing = true;

  static const String _sampleConfig = '''
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
''';

  @override
  void initState() {
    super.initState();
    _initializeVpn();
  }

  Future<void> _initializeVpn() async {
    try {
      await _vpnService.initialize();
    } catch (e) {
      print('خطا در مقداردهی اولیه VPN: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _toggleConnection() async {
    if (_isLoading || _isInitializing) return;
    setState(() => _isLoading = true);
    try {
      await _vpnService.toggleVpn(_sampleConfig);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isConnected = _vpnService.isConnected;

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('V2RAY stk'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('V2RAY stk'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator() else const SizedBox(height: 80),
            Icon(
              isConnected ? Icons.vpn_lock : Icons.vpn_key,
              size: 80,
              color: isConnected ? Colors.green : colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              isConnected ? '✅ وصل شده' : '❌ قطع است',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : colorScheme.error,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: (_isLoading || _isInitializing) ? null : _toggleConnection,
              icon: Icon(isConnected ? Icons.stop : Icons.play_arrow),
              label: Text(
                isConnected ? 'قطع اتصال' : 'اتصال',
                style: const TextStyle(fontSize: 18),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: isConnected ? colorScheme.error : colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== بقیه صفحات (تنظیمات، ادمین، مدیریت کانفیگ) بدون تغییر ==========
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPersian = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await PreferencesService.getLanguage();
    setState(() {
      _isPersian = lang == 'fa';
      _isLoading = false;
    });
  }

  Future<void> _toggleLanguage(bool value) async {
    final lang = value ? 'fa' : 'en';
    await PreferencesService.saveLanguage(lang);
    setState(() {
      _isPersian = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(_isPersian ? 'زبان: فارسی' : 'زبان: انگلیسی'),
                      trailing: Switch(
                        value: _isPersian,
                        onChanged: _toggleLanguage,
                        activeColor: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: const Text('مدیریت کانفیگ‌ها'),
                      subtitle: const Text('افزودن، ویرایش و حذف کانفیگ‌ها'),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('تنظیمات اتصال'),
                      subtitle: const Text('Kill Switch، Mux و ...'),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock_reset),
                      title: const Text('تغییر رمز عبور ادمین'),
                      subtitle: const Text('تغییر رمز عبور پنل مدیریت'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _message = '';

  Future<void> _changePassword() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _message = 'رمز جدید و تأیید آن مطابقت ندارند');
      return;
    }
    if (_newController.text.length < 4) {
      setState(() => _message = 'رمز جدید باید حداقل ۴ کاراکتر باشد');
      return;
    }
    final success = await PreferencesService.changePassword(
      _oldController.text,
      _newController.text,
    );
    if (success) {
      setState(() => _message = '✅ رمز عبور با موفقیت تغییر کرد');
      _oldController.clear();
      _newController.clear();
      _confirmController.clear();
    } else {
      setState(() => _message = '❌ رمز فعلی اشتباه است');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تغییر رمز عبور'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _oldController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'رمز فعلی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'رمز جدید',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأیید رمز جدید',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _changePassword,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('تغییر رمز'),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('✅') ? Colors.green : Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminWrapper extends StatefulWidget {
  const AdminWrapper({super.key});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return AdminPage(onLogout: () {
        setState(() {
          _isLoggedIn = false;
        });
      });
    } else {
      return AdminLoginPage(onLogin: () {
        setState(() {
          _isLoggedIn = true;
        });
      });
    }
  }
}

class AdminLoginPage extends StatefulWidget {
  final VoidCallback onLogin;

  const AdminLoginPage({super.key, required this.onLogin});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    final correctPassword = await PreferencesService.getPassword();
    if (_passwordController.text == correctPassword) {
      widget.onLogin();
    } else {
      setState(() {
        _errorMessage = 'رمز عبور اشتباه است';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ورود به پنل ادمین'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'ورود',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class AdminPage extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminPage({super.key, required this.onLogout});

  void _showQrPlaceholder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسکن QR'),
        content: const Text(
          'قابلیت اسکن QR در حال توسعه است.\n'
          'به زودی اضافه می‌شود.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متوجه شدم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل ادمین'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'خروج از حساب',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              '✅ وارد شدید',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'در اینجا می‌توانید کانفیگ‌ها را مدیریت کنید',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfigManagementPage(),
                  ),
                );
              },
              icon: const Icon(Icons.vpn_key),
              label: const Text('مدیریت کانفیگ‌ها'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showQrPlaceholder(context),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('اسکن QR (به زودی)'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigManagementPage extends StatefulWidget {
  const ConfigManagementPage({super.key});

  @override
  State<ConfigManagementPage> createState() => _ConfigManagementPageState();
}

class _ConfigManagementPageState extends State<ConfigManagementPage> {
  List<Map<String, String>> _configs = [
    {'name': 'سرور ایران', 'address': 'ir.example.com', 'status': 'فعال'},
    {'name': 'سرور آلمان', 'address': 'de.example.com', 'status': 'غیرفعال'},
    {'name': 'سرور آمریکا', 'address': 'us.example.com', 'status': 'فعال'},
  ];

  String? _convertVlessToJson(String link) {
    if (!link.startsWith('vless://')) return null;

    try {
      final raw = link.substring(8);
      final atIndex = raw.indexOf('@');
      if (atIndex == -1) return null;

      final userPart = raw.substring(0, atIndex);
      final rest = raw.substring(atIndex + 1);
      final hostPort = rest.split('?')[0];
      final query = rest.contains('?') ? rest.split('?')[1] : '';

      final hostParts = hostPort.split(':');
      final address = hostParts[0];
      final port = int.tryParse(hostParts[1]) ?? 443;

      Map<String, String> params = {};
      if (query.isNotEmpty) {
        query.split('&').forEach((pair) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            params[parts[0]] = Uri.decodeComponent(parts[1]);
          }
        });
      }

      final path = params['path'] ?? '/';
      final security = params['security'] ?? 'tls';
      final encryption = params['encryption'] ?? 'none';
      final host = params['host'] ?? address;
      final sni = params['sni'] ?? host;
      final fp = params['fp'] ?? 'chrome';
      final type = params['type'] ?? 'ws';

      final jsonConfig = {
        "log": {"loglevel": "none"},
        "inbounds": [
          {
            "listen": "127.0.0.1",
            "port": 10808,
            "protocol": "socks",
            "settings": {"auth": "noauth", "udp": true}
          }
        ],
        "outbounds": [
          {
            "protocol": "vless",
            "settings": {
              "vnext": [
                {
                  "address": address,
                  "port": port,
                  "users": [
                    {"id": userPart, "encryption": encryption}
                  ]
                }
              ]
            },
            "streamSettings": {
              "network": type,
              "security": security,
              "tlsSettings": {"serverName": sni, "fingerprint": fp},
              "wsSettings": {
                "path": path,
                "headers": {"Host": host}
              }
            }
          }
        ]
      };

      return const JsonEncoder.withIndent('  ').convert(jsonConfig);
    } catch (e) {
      return null;
    }
  }

  void _addConfigViaLink() {
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('وارد کردن لینک اشتراک'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('لینک vless:// یا vmess:// خود را وارد کنید:'),
            const SizedBox(height: 12),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'لینک',
                border: OutlineInputBorder(),
                hintText: 'vless://...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final link = linkController.text.trim();
              if (link.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لطفاً لینک را وارد کنید')),
                );
                return;
              }

              String? jsonConfig;
              String name = '';

              if (link.startsWith('vless://')) {
                jsonConfig = _convertVlessToJson(link);
                name = 'VLESS - ${link.substring(8).split('@')[1].split('?')[0]}';
              } else if (link.startsWith('vmess://')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('پشتیبانی از vmess به زودی اضافه می‌شود')),
                );
                return;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فرمت لینک پشتیبانی نمی‌شود')),
                );
                return;
              }

              if (jsonConfig == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطا در تبدیل لینک')),
                );
                return;
              }

              setState(() {
                _configs.add({
                  'name': name,
                  'address': jsonConfig!,
                  'status': 'غیرفعال',
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ کانفیگ با موفقیت اضافه شد')),
              );
            },
            child: const Text('تبدیل و افزودن'),
          ),
        ],
      ),
    );
  }

  void _addConfig() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final addressController = TextEditingController();
        return AlertDialog(
          title: const Text('افزودن کانفیگ جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'نام'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'آدرس (JSON)'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                  setState(() {
                    _configs.add({
                      'name': nameController.text,
                      'address': addressController.text,
                      'status': 'غیرفعال',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('افزودن'),
            ),
          ],
        );
      },
    );
  }

  void _deleteConfig(int index) {
    setState(() {
      _configs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کانفیگ‌ها'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: _addConfigViaLink,
            tooltip: 'وارد کردن لینک',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addConfig,
            tooltip: 'افزودن کانفیگ دستی',
          ),
        ],
      ),
      body: _configs.isEmpty
          ? const Center(
              child: Text('هیچ کانفیگی وجود ندارد'),
            )
          : ListView.builder(
              itemCount: _configs.length,
              itemBuilder: (context, index) {
                final config = _configs[index];
                final isJson = config['address']?.startsWith('{') ?? false;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: Text(config['name'] ?? 'بدون نام'),
                    subtitle: Text(
                      isJson
                          ? 'JSON (${config['address']?.length ?? 0} کاراکتر)'
                          : (config['address'] ?? 'بدون آدرس'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: config['status'] == 'فعال'
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            config['status'] ?? 'نامشخص',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteConfig(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
