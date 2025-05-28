import 'package:go_router/go_router.dart';
import 'package:example_tmap_navi/pages/drive/drive_page.dart';
import 'package:example_tmap_navi/pages/root/root_page.dart';

import '../pages/location/location_picker_page.dart';

class AppRoutes {
  static const initialPage = AppRoutes.rootPage;

  static const rootPage = '/';
  static const drivePage = '/drive';
}

GoRouter router() {
  return GoRouter(
    initialLocation: AppRoutes.initialPage,
    routes: [
      GoRoute(
        path: '/location/start',
        builder: (_, __) => const LocationPickerPage(mode: PickMode.start),
      ),
      GoRoute(
        path: '/location/destination',
        builder: (_, __) => const LocationPickerPage(mode: PickMode.destination),
      ),
      GoRoute(
          path: AppRoutes.rootPage,
          builder: (context, state) => const RootPage(),
          routes: [
            GoRoute(
              path: 'drive',
              builder: (context, state) => const DrivePage(),
            ),
          ]
      ),
    ],
  );
}
