import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/utils/color.dart';

class AddNoteCard extends StatefulWidget {
  const AddNoteCard({Key? key}) : super(key: key);

  @override
  State<AddNoteCard> createState() => _AddNoteCardState();
}

class _AddNoteCardState extends State<AddNoteCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomSlide(
        color: NotedColors.primary,
        onTap: () {},
        actions: null,
        //TODO : add traduction
        titleWidget: Text(
          "Ajouter une nouvelle note".tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        withWidget: true,
        avatarWidget: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 40,
          width: 40,
          child: const Icon(
            Icons.add_circle_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
