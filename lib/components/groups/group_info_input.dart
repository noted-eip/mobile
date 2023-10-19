import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/utils/theme_helper.dart';

class GroupInfosInput extends ConsumerStatefulWidget {
  const GroupInfosInput(
      {required this.formKey,
      required this.descriptionController,
      required this.titleController,
      required this.title,
      super.key});

  final String title;

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupInfosInputState();
}

class _GroupInfosInputState extends ConsumerState<GroupInfosInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 32,
        ),
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: widget.titleController,
                decoration: ThemeHelper()
                    .textInputDecoration('Titre du groupe', 'Entre un Titre'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Entrer un Titre";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                controller: widget.descriptionController,
                decoration: ThemeHelper().textInputDecoration(
                    'Description du Groupe', 'Entrer une Description'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Entrer une Description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
