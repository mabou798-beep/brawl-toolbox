import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/ads/ads_bootstrap.dart';
import 'core/api/brawl_api_service.dart';
import 'core/api/events_api_service.dart';
import 'core/api/player_api_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/brawlers_provider.dart';
import 'providers/events_provider.dart';
import 'providers/maps_provider.dart';
import 'providers/player_provider.dart';
import 'screens/root_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAds();
  runApp(const BrawlFanApp());
}

class BrawlFanApp extends StatelessWidget {
  const BrawlFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = BrawlApiService();
    final playerApi = PlayerApiService();
    final eventsApi = EventsApiService();

    return MultiProvider(
      providers: [
        Provider<BrawlApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => BrawlersProvider(api)..load()),
        ChangeNotifierProvider(create: (_) => MapsProvider(api)..load()),
        ChangeNotifierProvider(create: (_) => EventsProvider(eventsApi)..load()),
        // restore() is a no-op until the player has saved a tag.
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(playerApi)..restore(),
        ),
      ],
      child: MaterialApp(
        title: 'Brawl Toolbox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const RootShell(),
      ),
    );
  }
}
