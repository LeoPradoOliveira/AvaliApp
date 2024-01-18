import 'dart:io';
import 'package:avaliapp/components/profile_text_box.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final storage = FirebaseStorage.instance;
  final usersCollection = FirebaseFirestore.instance.collection("users");

  Future<void> uploadProfileImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;
      popContext();

      String userDirectory = currentUser.uid;
      Reference referenceRoot = FirebaseStorage.instance.ref().child('users');
      Reference referenceDireImages = referenceRoot.child(userDirectory);
      Reference referenceImageToUpload = referenceDireImages.child('Foto');

      UploadTask uploadTask =
          referenceImageToUpload.putFile(File(pickedFile.path));
      TaskSnapshot uploadSnapshot = await uploadTask;

      String downloadURL = await uploadSnapshot.ref.getDownloadURL();

      await usersCollection.doc(currentUser.uid).update({'Foto': downloadURL});
    } catch (e) {
      return;
    }
  }

  //Não acho que isso seja uma boa prática, mas o compilador não reclama
  void popContext() {
    Navigator.of(context).pop();
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[300],
        title: Text(
          "Editar $field",
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Insira o novo $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 35, 60),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userData['Foto'],
                          ),
                          radius: 80,
                        ),
                        Positioned(
                          right: 100,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => bottomSheet()),
                              );
                            },
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      currentUser.email!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Text("Informações do usuário"),
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
                          child: Icon(Icons.info_rounded),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[400],
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                    ProfileTextBox(
                      text: userData['Nome'],
                      sectionName: 'Nome',
                      onPressed: () => editField('Nome'),
                    ),
                    ProfileTextBox(
                      text: userData['Instituição'],
                      sectionName: 'Instituição',
                      onPressed: () => editField('Instituição'),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro${snapshot.error}',
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Escolher Foto",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.camera,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    uploadProfileImage(ImageSource.camera);
                  },
                  label: const Text(
                    "Câmera",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.image,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    uploadProfileImage(ImageSource.gallery);
                  },
                  label: const Text("Galeria",
                      style: TextStyle(
                        color: Colors.green,
                      )),
                ),
              ])
        ],
      ),
    );
  }
}