import 'package:alhy_momken_task/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class DocumentInputDialog extends StatefulWidget {
  @override
  _DocumentInputDialogState createState() => _DocumentInputDialogState();
}

class _DocumentInputDialogState extends State<DocumentInputDialog> {
  final TextEditingController _urlController = TextEditingController();
  String fileType = 'pdf'; // Default file type

  void _openDocumentViewer(BuildContext context) {
    String url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid URL")),
      );
      return;
    }

    Navigator.pop(context, {'url': url, 'fileType': fileType});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Document URL"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _urlController,
            hintText:  "Enter a valid file URL",

            keyboardType: TextInputType.url, isSecuredField: false,
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: fileType,
            onChanged: (String? newValue) {
              setState(() {
                fileType = newValue!;
              });
            },
            items: ['pdf', 'doc'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => _openDocumentViewer(context),
          child: const Text("Open"),
        ),
      ],
    );
  }
}
