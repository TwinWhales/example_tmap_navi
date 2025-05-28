import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tmap_ui_sdk/event/data/driveStatus/tmap_drivestatus.dart';
import 'package:tmap_ui_sdk/event/data/driveguide/tmap_driveguide.dart';
import 'package:tmap_ui_sdk/event/data/markerStatus/marker_status.dart';
import 'package:tmap_ui_sdk/event/data/sdkStatus/tmap_sdk_status.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk_manager.dart';
import 'package:tmap_ui_sdk/widget/tmap_view_widget.dart';
import 'package:example_tmap_navi/models/drive_model.dart';
import 'package:example_tmap_navi/routes/app_routes.dart';
import 'package:example_tmap_navi/utils/continue_drive_utils.dart';

// Tmap의 UI와 함께 주행
class DrivePage extends StatefulWidget {
  const DrivePage({super.key});

  @override
  State<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  int _currentSpeed = 0;
  int _averageSpeed = 0;

  @override
  void initState() {
    super.initState();
    TmapUISDKManager().startTmapSDKStatusStream(_onEvent);
    TmapUISDKManager().startMarkerStatusStream(_onMarkerEvent);
    TmapUISDKManager().startTmapDriveStatusStream(_onDriveStatus);
    // ★ 기존 구독에 더해, 드라이브 가이드(속도 포함) 스트림 구독
    TmapUISDKManager().startTmapDriveGuideStream(_onDriveGuide);
  }

  void _onDriveStatus(TmapDriveStatus status) {
    if (status == TmapDriveStatus.onArrivedDestination) {
      debugPrint('[onDriveStatus] - onArrived');
    }
  }

  // ★ 수정: 가이드 이벤트에서 속도 업데이트
  void _onDriveGuide(TmapDriveGuide guide) {
    setState(() {
      _currentSpeed = guide.speedInKmPerHour;
      _averageSpeed = guide.averageSpeed;
    });

    debugPrint(
        '[onDriveGuide] Speed: ${guide.speedInKmPerHour} km/h, '
            'Location(${guide.matchedLatitude},${guide.matchedLongitude})'
    );
    debugPrint('[onDriveGuide] - matched Location(${guide.matchedLatitude},${guide.matchedLongitude}) ${guide.currentCourseAngle}');
    debugPrint('[onDriveGuide] - firstSDIInfo: ${guide.firstSDIInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - secondSDIInfo: ${guide.secondSDIInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - secondTBTInfo: ${guide.secondTBTInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - remainViaPointSize: ${guide.remainViaPointSize}');
  }

  void _onEvent(TmapSDKStatusMsg sdkStatus) {
    switch (sdkStatus.sdkStatus) {
      case TmapSDKStatus.dismissReq:
        if (context.mounted) context.go(AppRoutes.rootPage);
        break;
      case TmapSDKStatus.continueDriveRequestedButNoSavedDriveInfo:
        ContinueDriveUtil.alertContinueDrive(
          context,
          destination: sdkStatus.extraData,
          onGranted: () {
            if (context.mounted) context.go(AppRoutes.rootPage);
          },
        );
        break;
      default:
        break;
    }
  }

  void _onMarkerEvent(MarkerStatus selectedMarker) {
    debugPrint(
        'MarkerSelected - ID:${selectedMarker.markerId} '
            'type:${selectedMarker.markerType}'
    );
  }

  @override
  void dispose() {
    TmapUISDKManager().stopTmapSDKStatusStream();
    TmapUISDKManager().stopMarkerStatusStream();
    TmapUISDKManager().stopTmapDriveStatusStream();
    TmapUISDKManager().stopTmapDriveGuideStream(); // ★ 구독 해제
    super.dispose();
  }

  Future<bool?> stopDriving() async {
    return await TmapUISDKManager().stopDriving();
  }

  Future<bool?> toNextViaPointRequest() async {
    return await TmapUISDKManager().toNextViaPointRequest();
  }

  @override
  Widget build(BuildContext context) {
    // ★ 계산: 속도 ×2
    final displayedSpeed = _currentSpeed * 2;

    return WillPopScope(
      onWillPop: () async {
        await stopDriving();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // 기존 지도 UI
              Container(
                color: Colors.white,
                child: Consumer<DriveModel>(
                  builder: (context, drive, child) =>
                      TmapViewWidget(data: drive.routeRequestData),
                ),
              ),
              // ★ 속도 표시 영역 (좌측 상단)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '속도: $displayedSpeed km/h',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
