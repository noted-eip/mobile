import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer(
      {Key? key,
      required this.titleWidget,
      required this.body,
      this.primaryColor,
      this.secondaryColor,
      this.notif})
      : super(key: key);

  final Widget titleWidget;
  final Widget body;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool? notif;

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
              backgroundColor: primaryColor ?? Colors.white,
              leading: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Navigator.canPop(context)
                        ? CupertinoIcons.back
                        : Icons.menu,
                    color: secondaryColor ?? Colors.grey.shade900,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context, false);
                    } else {
                      ZoomDrawer.of(context)!.toggle();
                    }
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
                        icon: Icon(Icons.send,
                            size: 24,
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
