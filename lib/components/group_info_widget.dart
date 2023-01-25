import 'package:flutter/material.dart';
import 'package:noted_mobile/data/models/group/group.dart';
import 'package:shimmer/shimmer.dart';

class GroupInfos extends StatelessWidget {
  const GroupInfos({Key? key, required this.group}) : super(key: key);
  const GroupInfos.empty({Key? key}) : this(key: key, group: null);

  final Group? group;

  String intTo2Digits(int number) {
    if (number < 10) {
      return "0$number";
    }
    return number.toString();
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String day = intTo2Digits(dateTime.day);
    String month = intTo2Digits(dateTime.month);
    String year = dateTime.year.toString();
    String hour = intTo2Digits(dateTime.hour);
    String minute = intTo2Digits(dateTime.minute);

    return "$day/$month/$year : $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    if (group == null) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(
                0.0,
                10.0,
              ),
            )
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 24,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 24,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade700,
              child: Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 18,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 18,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(
              0.0,
              10.0,
            ),
          )
        ],
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
                    "0",
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
                    Icons.schedule,
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(
                    width: 180,
                    child: Text(
                      formatDate(group!.data.created_at),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
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
            group!.data.description,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
