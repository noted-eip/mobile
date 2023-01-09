import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/theme_helper.dart';

typedef StringCallback = void Function(String role);

class InviteForm extends StatefulWidget {
  const InviteForm(
      {super.key, required this.controller, required this.selectedRoles});

  final List<TextEditingController> controller;
  final List<String> selectedRoles;

  @override
  State<InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<InviteForm> {
  List<InviteField> _buildList() {
    List<InviteField> inviteFields = [];

    widget.controller.asMap().forEach((index, value) {
      inviteFields.add(
        InviteField(
          emailController: value,
          index: index,
          onTap: () => deleteField(index),
          onRoleChange: (role) {
            setRole(role, index);
          },
        ),
      );
    });

    return inviteFields;
  }

  void addField() {
    setState(() {
      widget.controller.add(TextEditingController());
      widget.selectedRoles.add("admin");
    });
  }

  void deleteField(int index) {
    setState(() {
      widget.controller.removeAt(index);
      widget.selectedRoles.removeAt(index);
    });
  }

  void setRole(String value, int index) {
    setState(() {
      widget.selectedRoles[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildList(),
          TextButton(
              onPressed: () {
                addField();
              },
              child: const Text("Add member"))
        ],
      ),
    );
  }
}

class InviteField extends StatefulWidget {
  const InviteField(
      {super.key,
      required this.emailController,
      required this.index,
      required this.onTap,
      this.first,
      required this.onRoleChange});

  final TextEditingController emailController;
  final int index;
  final VoidCallback onTap;
  final bool? first;
  final StringCallback onRoleChange;

  @override
  State<InviteField> createState() => _InviteFieldState();
}

class _InviteFieldState extends State<InviteField> {
  static List<String> roles = <String>['admin', 'user'];
  String dropdownValue = roles.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.emailController,
              decoration: ThemeHelper()
                  .textInputDecoration('Email', 'Enter an user email'),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Please enter an Email";
                }
                return null;
              },
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: TextStyle(color: Colors.grey.shade900),
            underline: Container(
              height: 2,
              color: Colors.grey.shade900,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              widget.onRoleChange(value!);
              setState(() {
                dropdownValue = value;
              });
            },
            items: roles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(
            width: 16,
          ),
          if (widget.first == null)
            IconButton(
              onPressed: widget.onTap,
              icon: const Icon(Icons.close),
              iconSize: 32,
            )
        ],
      ),
    );
  }
}
