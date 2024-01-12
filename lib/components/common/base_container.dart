import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

class BaseContainer extends ConsumerStatefulWidget {
  const BaseContainer({
    Key? key,
    required this.titleWidget,
    required this.body,
    this.primaryColor,
    this.secondaryColor,
    this.notif,
    this.openDrawer,
    this.openEndDrawer,
  }) : super(key: key);

  final Widget titleWidget;
  final Widget body;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool? notif;
  final bool? openDrawer;
  final bool? openEndDrawer;

  @override
  ConsumerState<BaseContainer> createState() => _BaseContainerState();
}

class _BaseContainerState extends ConsumerState<BaseContainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: widget.primaryColor ?? Colors.white,
        child: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) => [
            CupertinoSliverNavigationBar(
              brightness: Brightness.light,
              border: null,
              padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
              backgroundColor: widget.primaryColor ?? Colors.white,
              leading: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.transparent,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    widget.openDrawer != null && !widget.openDrawer!
                        ? CupertinoIcons.back
                        : Navigator.canPop(context)
                            ? CupertinoIcons.back
                            : Icons.menu,
                    color: widget.secondaryColor ?? Colors.grey.shade900,
                  ),
                  onPressed: () {
                    if (widget.openDrawer != null && !widget.openDrawer! ||
                        Navigator.canPop(context)) {
                      Navigator.pop(context, false);
                    } else {
                      final bool hasDrawer = ref
                          .read(mainScreenProvider)
                          .scaffoldKey
                          .currentState!
                          .hasDrawer;

                      if (hasDrawer) {
                        ref
                            .read(mainScreenProvider)
                            .scaffoldKey
                            .currentState!
                            .openDrawer();
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    }
                  },
                ),
              ),
              largeTitle: widget.titleWidget,
              trailing: widget.notif != null && widget.notif!
                  ? const SizedBox()
                  : Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: (() {
                          if (widget.openEndDrawer != null &&
                              !widget.openEndDrawer!) {
                            Navigator.pushNamed(context, "/notif");
                          } else {
                            final bool hasDrawer = ref
                                .read(mainScreenProvider)
                                .scaffoldKey
                                .currentState!
                                .hasEndDrawer;

                            if (hasDrawer) {
                              ScaffoldState? scaffoldState = ref
                                  .read(mainScreenProvider)
                                  .scaffoldKey
                                  .currentState;

                              if (scaffoldState == null ||
                                  !scaffoldState.hasEndDrawer) {
                                Navigator.of(context).pushNamed('/notif');
                                return;
                              }

                              scaffoldState.openEndDrawer();
                            }

                            Scaffold.of(context).openEndDrawer();
                          }

                          ref
                              .read(trackerProvider)
                              .trackPage(TrackPage.notification);
                        }),
                        iconSize: 24,
                        icon: Icon(Icons.send_rounded,
                            color:
                                widget.secondaryColor ?? Colors.grey.shade900),
                      ),
                    ),
            ),
          ],
          body: widget.body,
        ),
      ),
    );
  }
}
