
import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController textController;
  final String hinText;
const BlogEditor({ super.key, required this.textController, required this.hinText });

  @override
  Widget build(BuildContext context){
    return TextFormField(
        controller: textController,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hinText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
    );
  }
}