import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer({
    Key? key,
    required this.titleWidget,
    required this.body,
    this.primaryColor,
    this.secondaryColor,
    this.notif,
    this.openDrawer,
  }) : super(key: key);

  final Widget titleWidget;
  final Widget body;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool? notif;
  final bool? openDrawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: primaryColor ?? Colors.white,
        child: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) => [
            CupertinoSliverNavigationBar(
              brightness: Brightness.light,
              border: null,
              padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
              backgroundColor: primaryColor ?? Colors.white,
              leading: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.transparent,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    openDrawer != null && !openDrawer!
                        ? CupertinoIcons.back
                        : Navigator.canPop(context)
                            ? CupertinoIcons.back
                            : Icons.menu,
                    color: secondaryColor ?? Colors.grey.shade900,
                  ),
                  onPressed: () {
                    if (openDrawer != null && !openDrawer! ||
                        Navigator.canPop(context)) {
                      Navigator.pop(context, false);
                    } else {
                      ZoomDrawer.of(context)!.toggle();
                    }

                    // if (Navigator.canPop(context)) {
                    //   Navigator.pop(context, false);
                    // } else {
                    //   ZoomDrawer.of(context)!.toggle();
                    // }
                  },
                ),
              ),
              largeTitle: titleWidget,
              trailing: notif != null && notif!
                  ? const SizedBox()
                  : Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: (() {
                          if (kDebugMode) {
                            print("Send button pressed");
                          }
                          Navigator.pushNamed(context, "/notif");
                        }),
                        iconSize: 24,
                        icon: Icon(Icons.send_rounded,
                            color: secondaryColor ?? Colors.grey.shade900),
                      ),
                    ),
            ),
          ],
          body: body,
        ),
      ),
    );
  }
}
