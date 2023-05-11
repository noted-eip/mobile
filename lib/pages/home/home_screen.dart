import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';
import 'package:noted_mobile/components/home/home_infos_widget.dart';
import 'package:noted_mobile/components/notes/latest_notes_widget.dart';
import 'package:noted_mobile/components/groups/latest_groups_widget.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:noted_mobile/data/providers/group_provider.dart';
import 'package:noted_mobile/data/providers/note_provider.dart';
import 'package:noted_mobile/pages/notifications/notification_page.dart';

import 'package:flutter/material.dart';

class Product {
  final String name;
  final String category;
  final double price;

  Product({required this.name, required this.category, required this.price});
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<List<Group>?> groups;
  // final List<Product> _products = [
  //   Product(name: 'T-shirt', category: 'Vêtements', price: 20.0),
  //   Product(name: 'Jeans', category: 'Vêtements', price: 50.0),
  //   Product(name: 'Ordinateur ', category: 'Inform', price: 1000.0),
  //   Product(
  //       name: 'Ordinateur portable', category: 'Informatique', price: 1000.0),
  //   Product(name: 'Souris', category: 'Informatique', price: 20.0),
  // ];

  // // map of categorie and isExpanded
  // Map<String, bool> _isExpanded = {};

  // @override
  // Widget build(BuildContext context) {
  //   // Trier la liste par catégorie
  //   _products.sort((a, b) => a.category.compareTo(b.category));

  //   // Créer une liste de ExpansionPanel à partir des catégories triées
  //   List<ExpansionPanel> expansionPanels = [];
  //   String? _currentCategory;

  //   for (int i = 0; i < _products.length; i++) {
  //     Product product = _products[i];
  //     if (_currentCategory != product.category) {
  //       expansionPanels.add(
  //         ExpansionPanel(
  //           headerBuilder: (context, isExpanded) {
  //             return ListTile(
  //               title: Text(product.category),
  //             );
  //           },
  //           body: ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount:
  //                 _products.where((p) => p.category == product.category).length,
  //             itemBuilder: (context, index) {
  //               Product product = _products
  //                   .where((p) => p.category == _currentCategory)
  //                   .toList()[index];
  //               return ListTile(
  //                 title: Text(product.name),
  //                 subtitle: Text('${product.price} €'),
  //               );
  //             },
  //           ),
  //           isExpanded: true,
  //         ),
  //       );
  //       _currentCategory = product.category;
  //     }
  //   }

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Liste de produits triés par catégorie'),
  //     ),
  //     body: SingleChildScrollView(
  //       child: ExpansionPanelList(
  //         expansionCallback: (index, isExpanded) {
  //           // setState(() {
  //           //   expansionPanels[index].isExpanded = !isExpanded;
  //           // });
  //         },
  //         children: expansionPanels,
  //       ),
  //     ),
  //   );

  @override
  Widget build(BuildContext context) {
    final homePageHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight,
        title: const Text('NOTED', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.only(left: 4),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                print('menu button pressed');
                // open drawer
                Scaffold.of(context).openDrawer();
                // ZoomDrawer.of(context)!.toggle();
                // ZoomDrawer.of(context)!.open();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          );
        }),
        actions: const [
          NotifButton(),
        ],
        elevation: 0,
      ),
      // drawer: Drawer(
      //   child: Column(
      //     children: [
      //       const DrawerHeader(
      //         child: Text('Drawer Header'),
      //       ),
      //       ListTile(
      //         title: const Text('Item 1'),
      //         onTap: () {
      //           // Update the state of the app
      //           // ...
      //           // Then close the drawer
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         title: const Text('Item 2'),
      //         onTap: () {
      //           // Update the state of the app
      //           // ...
      //           // Then close the drawer
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      // drawer: Drawer(
      //   backgroundColor: Colors.grey.shade900,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.grey.shade900,
      //         ),
      //         child: Column(
      //           children: [
      //             CircleAvatar(
      //               radius: 50,
      //               backgroundColor: Colors.white,
      //               child: const Image(
      //                 image: AssetImage('./images/noted_logo.png'),
      //                 fit: BoxFit.fill,
      //                 height: 70.0,
      //                 width: 70.0,
      //               ),
      //             ),
      //             const Text(
      //               'Noted',
      //               style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 30,
      //                   fontWeight: FontWeight.bold),
      //             ),
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.message),
      //         title: Text('Messages'),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.account_circle),
      //         title: Text('Profile'),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.settings),
      //         title: Text('Settings'),
      //       ),
      //     ],
      //   ),
      // ),
      // drawer: const MyDrawer(),
      endDrawer: const NotificationPage(),
      body: SafeArea(
        child: RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            ref.invalidate(latestGroupsProvider);
            ref.invalidate(notesProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: homePageHeight,
                child: Column(
                  children: const [
                    Expanded(flex: 2, child: HomeInfos()),
                    Expanded(flex: 4, child: LatestsGroups()),
                    Expanded(flex: 6, child: LatestFiles()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotifButton extends StatelessWidget {
  const NotifButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: (() {
          Scaffold.of(context).openEndDrawer();
          // Navigator.pushNamed(context, "/notif");
        }),
        icon: const Icon(Icons.send, color: Colors.black),
      ),
    );
  }
}
