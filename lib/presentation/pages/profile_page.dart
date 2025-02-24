import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/presentation/providers/theme_provider.dart'; 
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/language_provider.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
              title: Text(
                authProvider.user?.displayName ?? 'Profile',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              (authProvider.user?.displayName ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.user?.displayName ?? '',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.user?.email ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Task Statistics
                  Text(
                    'Task Statistics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 48,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    todoProvider.completedTasks.toString(),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'Completed',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pending_outlined,
                                    size: 48,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    todoProvider.pendingTasks.toString(),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  Text(
                                    'Pending',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
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

                  // Settings
                  Text(
                    'Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.language,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Language'),
                          trailing: DropdownButton<String>(
                            value: languageProvider.currentLanguage,
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text('العربية'),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français'),
                              ),
                              DropdownMenuItem(
                                value: 'es',
                                child: Text('Español'),
                              ),
                              DropdownMenuItem(
                                value: 'de',
                                child: Text('Deutsch'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                languageProvider.changeLanguage(context, value);
                              }
                            },
                          ),
                        ),
                        Divider(color: Colors.grey[200]),
                        ListTile(
                          leading: Icon(
                            themeProvider.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : themeProvider.themeMode == ThemeMode.light
                                    ? Icons.light_mode
                                    : Icons.brightness_auto,
                          ),
                          title: const Text('Theme Mode'),
                          trailing: DropdownButton<ThemeMode>(
                            value: themeProvider.themeMode,
                            items: ThemeMode.values.map((mode) {
                              String label;
                              IconData icon;
                              switch (mode) {
                                case ThemeMode.system:
                                  label = 'System';
                                  icon = Icons.brightness_auto;
                                  break;
                                case ThemeMode.light:
                                  label = 'Light';
                                  icon = Icons.light_mode;
                                  break;
                                case ThemeMode.dark:
                                  label = 'Dark';
                                  icon = Icons.dark_mode;
                                  break;
                              }
                              return DropdownMenuItem(
                                value: mode,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 20),
                                    const SizedBox(width: 8),
                                    Text(label),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (ThemeMode? newMode) {
                              if (newMode != null) {
                                themeProvider.setThemeMode(newMode);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
