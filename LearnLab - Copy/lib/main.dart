import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hive_flutter/hive_flutter.dart";

import "core/notifications.dart";
import "router.dart";
import "theme.dart";

late final FlutterLocalNotificationsPlugin _notifications;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _notifications = FlutterLocalNotificationsPlugin();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await initNotifications(_notifications);
  runApp(const ProviderScope(child: LearnLabApp()));
}

class LearnLabApp extends ConsumerWidget {
  const LearnLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(routerProvider);
    return MaterialApp.router(
      title: "LearnLab",
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}