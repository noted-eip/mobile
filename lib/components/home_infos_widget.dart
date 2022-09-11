import 'package:flutter/material.dart';
import 'package:noted_mobile/data/user_provider.dart';
import 'package:provider/provider.dart';

class HomeInfos extends StatelessWidget {
  const HomeInfos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Hello,\n',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: userProvider.username == ''
                            ? 'Username !\n'
                            : '${userProvider.username} !\n',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: 'Let\'s write our first note !',
                        style: TextStyle(color: Colors.grey)),
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
