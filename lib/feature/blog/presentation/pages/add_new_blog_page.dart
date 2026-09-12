import 'dart:io';

import 'package:blog_diego/core/common/widgets/cubits/app_user/app_user_cubit.dart';
import 'package:blog_diego/core/theme/app_pallet.dart';
import 'package:blog_diego/core/utils/pick_image.dart';
import 'package:blog_diego/core/utils/show_snackbar.dart';
import 'package:blog_diego/feature/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_diego/feature/blog/presentation/pages/blog_page.dart';
import 'package:blog_diego/feature/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const AddNewBlogPage());
  const AddNewBlogPage({super.key});
  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final List<String> selectedTopics = [];
  File? image;
  final formKey = GlobalKey<FormState>();
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void _uploadBlog() {
    if (formKey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        image != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<BlogBloc>().add(
        BlogUpload(
          posterId: posterId,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          image: image!,
          topics: selectedTopics,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () {
              _uploadBlog();
            },
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogSucess) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    image != null
                        ? GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(10),
                                child: Image.file(image!, fit: BoxFit.cover),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: DottedBorder(
                              options: RectDottedBorderOptions(
                                color: AppPallet.secondaryDark,
                                strokeCap: StrokeCap.round,
                                dashPattern: const [10, 4],
                              ),

                              child: Container(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.folder_open, size: 40),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Add Image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                                  'Tecnology',
                                  'Business',
                                  'Programming',
                                  'Entretarinment',
                                ]
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedTopics.contains(e)) {
                                            selectedTopics.remove(e);
                                          } else {
                                            selectedTopics.add(e);
                                          }
                                        });
                                      },
                                      child: Chip(
                                        label: Text(e),
                                        color: selectedTopics.contains(e)
                                            ? WidgetStatePropertyAll(
                                                AppPallet.primaryLightAccent,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                    BlogEditor(
                      hinText: 'Blog Title',
                      textController: titleController,
                    ),
                    SizedBox(height: 10),
                    BlogEditor(
                      hinText: 'Blog Content',
                      textController: contentController,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
