import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final accountController = TextEditingController();
  final dateController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// โหลดข้อมูล
  Future loadUserData() async {

    var data = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if(data.exists){

      usernameController.text = data["username"] ?? "";
      emailController.text = data["email"] ?? "";
      accountController.text = data["accountName"] ?? "";
      dateController.text = data["date"] ?? "";

    }

  }

  /// update
  Future updateProfile() async {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .update({

      "username": usernameController.text,
      "email": emailController.text,
      "accountName": accountController.text,
      "date": dateController.text,

    });

    setState(() {
      isEdit = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update Success")),
    );

  }

  /// delete
  Future deleteAccount() async {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .delete();

    await user!.delete();

  }

  Widget textField(String title, TextEditingController controller){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(

        controller: controller,
        enabled: isEdit,

        decoration: InputDecoration(

          labelText: title,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),

        ),

      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF6F3F5),

      appBar: AppBar(
        title: const Text("Your Profile"),
        centerTitle: true,
      ),

      body: Padding(

        padding: const EdgeInsets.symmetric(horizontal: 25),

        child: Column(

          children: [

            const SizedBox(height: 30),

            /// avatar
            const CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/300",
              ),
            ),

            const SizedBox(height: 25),

            /// fields
            textField("Username", usernameController),
            textField("Email", emailController),
            textField("Account Name", accountController),
            textField("Join Date", dateController),

            const SizedBox(height: 30),

            /// edit / save button
            SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(

                onPressed: (){

                  if(isEdit){
                    updateProfile();
                  }else{
                    setState(() {
                      isEdit = true;
                    });
                  }

                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3F5576),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  isEdit ? "Save" : "Edit Profile"
                ),

              ),
            ),

            const SizedBox(height: 15),

            /// delete
            SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(

                onPressed: (){

                  showDialog(
                    context: context,
                    builder: (context){

                      return AlertDialog(

                        title: const Text("Delete Account"),

                        content: const Text(
                            "คุณต้องการลบบัญชีใช่หรือไม่ ?"),

                        actions: [

                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),

                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                              deleteAccount();
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        ],
                      );

                    },
                  );

                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text("Delete Account"),

              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Pocket Money",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],

        ),

      ),

    );

  }
}