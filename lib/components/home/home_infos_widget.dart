import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/providers/provider_list.dart';
import 'package:noted_mobile/utils/string_extension.dart';

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
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "home.hello".tr(),
                style: const TextStyle(fontSize: 20, color: Colors.black),
                children: <TextSpan>[
                  const TextSpan(
                    text: '\n',
                  ),
                  TextSpan(
                      text: user.name == ''
                          ? 'Name !\n'
                          : '${user.name.capitalize()} !\n',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: 'home.start'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
