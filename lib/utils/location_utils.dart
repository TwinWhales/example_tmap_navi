import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';          // ← 추가
import 'package:example_tmap_navi/widgets/simple_dialog.dart';

class LocationUtils {
  /// 권한 요청만 담당. 권한이 생기면 onGranted() 호출해 줌.
  static Future<void> requestLocationPermission(
      BuildContext context, {
        required void Function() onGranted,
      }) async {
    final granted = await _requestLocationPermission();
    if (!granted) {
      if (context.mounted) {
        simpleDialog(
          context: context,
          titleText: '위치 권한이 필요합니다.',
          rightButtonText: '권한 설정 하기',
          onRightBtnPressed: () async {
            final again = await _requestLocationPermission();
            if (!again) {
              openAppSettings();
            } else {
              Navigator.pop(context);
              onGranted();
            }
          },
          shouldDismissOnTouchOutside: false,
        );
      }
    } else {
      onGranted();
    }
  }

  /// 실제 권한 요청
  static Future<bool> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    return status.isGranted;
  }

  /// 현재 위치(위도·경도)만 돌려주는 편의 메서드
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
