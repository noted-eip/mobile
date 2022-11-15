import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer(
      {Key? key,
      required this.titleWidget,
      required this.body,
      this.primaryColor,
      this.secondaryColor})
      : super(key: key);

  final Widget titleWidget;
  final Widget body;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: primaryColor ?? Colors.white,
        child: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) => [
            CupertinoSliverNavigationBar(
              brightness: Brightness.light,
              border: null,
              backgroundColor: primaryColor ?? Colors.white,
              // leading: IconButton(
              //   icon: Icon(
              //     Navigator.canPop(context) ? CupertinoIcons.back : Icons.menu,
              //     color: secondaryColor ?? Colors.grey.shade900,
              //   ),
              //   onPressed: () {
              //     if (Navigator.canPop(context)) {
              //       Navigator.pop(context);
              //     } else {
              //       ZoomDrawer.of(context)!.toggle();
              //     }
              //   },
              // ),
              largeTitle: titleWidget,
              // trailing: IconButton(
              //   onPressed: (() {}),
              //   icon: Icon(Icons.send,
              //       size: 24, color: secondaryColor ?? Colors.grey.shade900),
              // ),
            ),
          ],
          body: body,
        ),
      ),
    );
  }
}
