import 'package:flutter/material.dart';
import 'package:noted_mobile/data/group.dart';

class GroupInfos extends StatelessWidget {
  const GroupInfos({Key? key, required this.group}) : super(key: key);
  final NewGroup group;

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} : ${date.hour}h${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "NB",
                    style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Notes",
                    style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.info_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      group.name,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text("Group Description",
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(
            group.description,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.grey.shade900,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    group.created_at,
                    style: TextStyle(color: Colors.grey.shade900),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
