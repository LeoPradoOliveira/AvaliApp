import 'dart:convert';
import 'package:avaliapp/components/my_button.dart';
import 'package:avaliapp/components/my_text_field.dart';
import 'package:avaliapp/components/square_tile.dart';
import 'package:avaliapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onTap});
  final Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

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

  void signUserUp() async {
    try {
      //Erro de confirmação da senha
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {

          final String file =
              await rootBundle.loadString('lib/components/answer_model.json');
          final answerModel = await json.decode(file);
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'E-mail': user.email,
            'Respostas': answerModel,
            'Foto':
                "https://firebasestorage.googleapis.com/v0/b/avaliapp-e041d.appspot.com/o/Fotos%2FdefaultProfilePicture.jpg?alt=media&token=29beb6cb-c6ca-4378-abf8-b94736d425c7",
            'Instituição': "Insira o nome da sua instituição",
            'Nome': "Insira o seu nome",
          });
        }
      } else {
        errorMessage("As senhas não coincidem");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        errorMessage("E-mail inválido");
      } else if (e.code == 'email-already-in-use') {
        errorMessage("E-mail já cadastrado");
      } else if (e.code == 'weak-password') {
        errorMessage("Senha muito fraca");
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
                const SizedBox(height: 30),
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
                const SizedBox(height: 10),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirme a senha',
                    obscureText: true),
                //
                const SizedBox(height: 20),
                //
                MyButton(
                  onTap: () {
                    if (!isLoading) {
                      signUserUp();
                    }
                  },
                  text: 'Cadastrar',
                ),
                if (isLoading)
                  const Column(
                    children: [
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ),
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
                        height: 70),
                  ],
                ),
                //
                const SizedBox(height: 40),
                //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já possui uma conta?"),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: widget.onTap,
                      child: const Text(
                        "Faça o login",
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
