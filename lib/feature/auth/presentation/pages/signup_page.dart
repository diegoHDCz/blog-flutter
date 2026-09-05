import 'package:blog_diego/core/common/widgets/loader.dart';
import 'package:blog_diego/core/theme/app_pallet.dart';
import 'package:blog_diego/core/utils/show_snackbar.dart';
import 'package:blog_diego/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_diego/feature/auth/presentation/pages/login_page.dart';
import 'package:blog_diego/feature/auth/presentation/widgets/auth_field.dart';
import 'package:blog_diego/feature/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute(builder: (context) => const SignupPage());

  const SignupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  late final signInRecognizer = TapGestureRecognizer()
    ..onTap = () => Navigator.push(context, LoginPage.route());

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    signInRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AuthField(hintText: 'Name', controller: nameController),
                      const SizedBox(height: 15),
                      AuthField(
                        hintText: 'Email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      AuthField(
                        hintText: 'Password',
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      AuthGradientButton(
                        buttonText: 'Sign Up',
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              AuthSignUp(
                                name: nameController.text.trim(),
                                email: emailController.text
                                    .trim()
                                    .toLowerCase(),
                                password: passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: 'Alreadyhave an account? ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppPallet.primaryLight,
                                    decoration: TextDecoration.underline,
                                  ),
                              mouseCursor: SystemMouseCursors.click,
                              recognizer: signInRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is AuthLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Loader(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
