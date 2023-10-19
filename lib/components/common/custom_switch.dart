import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final SwitchSize size;
  final Color? activeColor;
  final Color? inActiveColor;
  final bool disabled;
  final bool defaultActive;
  final Function(bool)? onChanged;

  const CustomSwitch({
    Key? key,
    this.size = SwitchSize.medium,
    this.inActiveColor,
    this.activeColor,
    this.disabled = false,
    this.defaultActive = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _active = true;
  double _y = -0.4;
  double _opacity = 0.0;

  @override
  void initState() {
    _active = widget.defaultActive;
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _y = 0;
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width *
        0.22 *
        (widget.size == SwitchSize.small
            ? 0.9
            : widget.size == SwitchSize.medium
                ? 1
                : 1);
    final height = 30.0 *
        (widget.size == SwitchSize.small
            ? 0.9
            : widget.size == SwitchSize.medium
                ? 1
                : 1.1);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1000),
      child: AnimatedSlide(
        offset: Offset(0, _y),
        duration: const Duration(milliseconds: 1000),
        child: GestureDetector(
          onTap: () {
            if (widget.disabled) {
              return;
            }
            setState(() {
              _active = !_active;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(_active);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.disabled
                    ? Colors.white
                    : _active
                        ? widget.activeColor ?? Colors.green
                        : widget.inActiveColor ?? Colors.grey.shade900,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ]),
            width: width,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(
                        'USER',
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      )),
                      Expanded(
                          child: Text(
                        'ADMIN',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      )),
                    ],
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment:
                      _active ? Alignment.centerLeft : Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: double.infinity,
                    width: _active ? width / 1.9 : width / 1.7,
                    child: Card(
                      color: Colors.grey.shade100,
                      clipBehavior: Clip.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SwitchSize { small, medium, large }
