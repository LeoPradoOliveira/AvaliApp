import 'package:avaliapp/components/my_button.dart';
import 'package:avaliapp/components/my_text_field.dart';
import 'package:avaliapp/components/square_tile.dart';
import 'package:avaliapp/pages/auth/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avaliapp/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onTap});
  final Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void errorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        });
  }

  void signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      


    } on FirebaseAuthException catch (e) {
      if(emailController.text == ""){
        errorMessage("Insira um e-mail");
      }
      else if (passwordController.text == "") {
        errorMessage("Insira uma senha");
      }
      else if (e.code == 'invalid-email') {
        errorMessage("E-mail inválido");
      } else if (e.code == 'invalid-credential') {
        errorMessage("E-mail ou senha incorretos");
      } else {
        errorMessage("Um erro inesperado ocorreu");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                //
                Image.asset(
                  "lib/images/logo.png",
                  height: 150,
                ),
                //
                const SizedBox(height: 79),
                //
                MyTextField(
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false),
                //
                const SizedBox(height: 10),
                //
                MyTextField(
                    controller: passwordController,
                    hintText: 'Senha',
                    obscureText: true),
                //
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ForgotPasswordPage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Esqueceu sua senha?",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //
                const SizedBox(height: 20),
                //
                MyButton(
                  onTap: signUserIn,
                  text: 'Entrar',
                ),
                //
                const SizedBox(height: 30),
                //
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 0.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Ou continue com'),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
                //
                const SizedBox(height: 40),
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/googleLogo.png',
                      height: 70,
                    ),
                  ],
                ),
                //
                const SizedBox(height: 40),
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Ainda não possui uma conta?"),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        "Registre-se",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
