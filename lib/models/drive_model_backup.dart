import 'package:tmap_ui_sdk/route/data/planning_option.dart';
import 'package:tmap_ui_sdk/route/data/route_point.dart';
import 'package:tmap_ui_sdk/route/data/route_request_data.dart';

class DriveModel {
  static bool safeDriving = false;
  static bool continueDriving = false;

  RouteRequestData get routeRequestData =>
      getRouteRequestData(safeDriving: safeDriving, continueDriving: continueDriving);

  RouteRequestData getRouteRequestData({bool safeDriving = false, bool continueDriving = false}) {
    if (safeDriving || continueDriving) {
      return RouteRequestData(safeDriving: safeDriving, continueDriving: continueDriving);
    }

    List<PlanningOption> options = [
      PlanningOption.recommend,
      PlanningOption.shortest
    ];

    List<RoutePoint> wayPoints = [
      RoutePoint(latitude: 36.102305, longitude: 129.391364, name: "한동대학교 벧엘관"),
      RoutePoint(latitude: 36.082299, longitude: 129.398445, name: "하나로마트"),
    ];

    return RouteRequestData(
      source: RoutePoint(latitude: 36.102305, longitude: 129.391364, name: "한동대학교 벧엘관"),
      destination: RoutePoint(latitude: 36.082299, longitude: 129.398445, name: "하나로마트"),
      // wayPoints: wayPoints,
      routeOption: options,
    );
  }
}