import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer(
      {Key? key, required this.drawerFontSize, required this.drawerIconSize})
      : super(key: key);

  final double drawerIconSize;
  final double drawerFontSize;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [
              0.0,
              1.0
            ],
                colors: [
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ])),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: const Text(
                  "Noted",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.screen_lock_landscape_rounded,
                size: widget.drawerIconSize,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Splash Screen',
                style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/splash');
              },
            ),
            ListTile(
              leading: Icon(Icons.login_rounded,
                  size: widget.drawerIconSize,
                  color: Theme.of(context).colorScheme.secondary),
              title: Text(
                'Login Page',
                style: TextStyle(
                    fontSize: widget.drawerFontSize,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              height: 1,
            ),
            ListTile(
              leading: Icon(Icons.person_add_alt_1,
                  size: widget.drawerIconSize,
                  color: Theme.of(context).colorScheme.secondary),
              title: Text(
                'Registration Page',
                style: TextStyle(
                    fontSize: widget.drawerFontSize,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              height: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.password_rounded,
                size: widget.drawerIconSize,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Forgot Password Page',
                style: TextStyle(
                    fontSize: widget.drawerFontSize,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              height: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.verified_user_sharp,
                size: widget.drawerIconSize,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Verification Page',
                style: TextStyle(
                    fontSize: widget.drawerFontSize,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/forgot-password-verification');
              },
            ),
            Divider(
              color: Theme.of(context).primaryColor,
              height: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                size: widget.drawerIconSize,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                    fontSize: widget.drawerFontSize,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                prefs!.remove('token');
                prefs!.remove('email');
                prefs!.remove('username');
                prefs!.remove('id');

                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
