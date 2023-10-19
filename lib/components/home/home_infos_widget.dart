import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';

class HomeInfos extends ConsumerWidget {
  const HomeInfos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Salut,\n',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: user.name == '' ? 'Name !\n' : '${user.name} !\n',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                      text: 'Commençons à écrire notre histoire !',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
