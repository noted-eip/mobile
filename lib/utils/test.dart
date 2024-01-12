import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  List<Widget> _buildAccountTestButton() {
    List<Widget> buttons = [];
    var accountMapTest = ref.read(accountClientProvider).testAll();

    accountMapTest.forEach((key, value) {
      buttons.add(
        ElevatedButton(
          onPressed: () async {
            var messenger = ScaffoldMessenger.of(context);
            try {
              var response = await value();

              debugPrint(response.toString());
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            }
          },
          child: Text(key),
        ),
      );
    });

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [..._buildAccountTestButton()],
          ),
        ),
      ),
    );
  }
}
