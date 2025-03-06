import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BackButtonHandler extends StatefulWidget {
  final Widget child;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Future<bool> Function()? onBackButtonPressed;
  final double toastBottomOffset;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.scaffoldKey,
    this.onBackButtonPressed,
    this.toastBottomOffset = 0,
  });

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  DateTime? currentBackPressTime;

  Future<bool> onWillPop() async {
    // 커스텀 콜백이 있으면 그것을 우선 실행
    if (widget.onBackButtonPressed != null) {
      return widget.onBackButtonPressed!();
    }

    // scaffoldKey와 currentState가 null이 아니고 드로어가 열려있으면 닫고 바로 리턴
    if (widget.scaffoldKey?.currentState != null &&
        widget.scaffoldKey!.currentState!.isDrawerOpen) {
      widget.scaffoldKey!.currentState!.closeDrawer();
      return false;
    }

    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      FToast fToast = FToast();
      fToast.init(context);
      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          margin: EdgeInsets.only(bottom: widget.toastBottomOffset),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black54,
          ),
          child: Text(
            "한 번 더 누르면 종료됩니다.",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        gravity: ToastGravity.BOTTOM,
      );

      // 2초 후에 currentBackPressTime 초기화
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            currentBackPressTime = null;
          });
        }
      });

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: widget.child,
    );
  }
}
