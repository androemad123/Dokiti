import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';
class Collections extends StatelessWidget {
  const Collections({super.key});

  @override
  Widget build(BuildContext context) {
    final _searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Collections"),backgroundColor: Colors.transparent,),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: _searchController,
              hintText: "search your bookmark",
              isSecuredField: false,
              prefixIcon: Icons.search_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
