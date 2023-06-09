// create station form

import 'package:charge_station_finder/presentation/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_bloc.dart';
import '../../../domain/auth/models/signInFormForm.dart';
import '../core/widgets/appBar.dart';
import '../core/widgets/formField.dart';
import '../core/widgets/primaryButton.dart';
import '../create_station/widgets/inputFieldHeader.dart';

class SignIn extends StatefulWidget {
  static const String route = "/signIn";
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // global key
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (_, state) {
        if (state is AuthenticationStateError) {
          final snackBar = SnackBar(
            content: Text(state.message!),
            backgroundColor: Colors.redAccent,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is AuthenticationStateUserAuthenticated) {
          const snackBar =
              SnackBar(backgroundColor: Colors.green, content: Text('Success'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is AuthenticationStateAdminAuthenticated) {
          const snackBar =
              SnackBar(backgroundColor: Colors.green, content: Text('Success'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CHSAppBar.build(context, "Sign In", () {}, false),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InputFieldHeader(
                      text: "Email",
                    ),
                    CSFFormField(
                      hintText: "Email",
                      onChanged: () {},
                      obscureText: false,
                      controller: emailController,
                    ),
                    const InputFieldHeader(
                      text: "Password",
                    ),
                    CSFFormField(
                      hintText: "Password",
                      onChanged: () {},
                      obscureText: true,
                      controller: passwordController,
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    Center(
                        child: state is AuthenticationLoading
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                                text: "Sign In", onPressed: dispatchLogin)),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(child: Text('Create Account'), onTap: () {
                        context.go(AppRoutes.SignUp);
                      }),
                    )
                  ]),
            ),
          ),
        );
      },
    );
  }

  void dispatchLogin() {
    context.read<AuthenticationBloc>().add(LoginEvent(
        signInForm: SignInForm(
            email: emailController.text, password: passwordController.text)));
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
