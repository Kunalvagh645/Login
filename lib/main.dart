import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'app_constant.dart';
import 'model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final databaseReference =
      FirebaseDatabase.instance.ref().child(Constant.userBucket);

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  String? key;
  bool show = true;
  String? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.deepPurpleAccent,
              Colors.deepOrangeAccent,
            ],
          )),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              CircleAvatar(
                backgroundImage: imageFile == null
                    ? const AssetImage('assets/default_image.jpg')
                    : imageFile != null ? Image.network(imageFile!).image : circular(),
                child: bottomSheet(),
                radius: 50.0,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: fNameController,
                      decoration: InputDecoration(
                          hintText: 'First Name', border: border()),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: lNameController,
                      decoration: InputDecoration(
                          hintText: 'Last Name', border: border()),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      maxLength: 2,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      controller: ageController,
                      decoration: InputDecoration(
                          counterText: '', hintText: 'Age', border: border()),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  show
                      ? ElevatedButton(
                          onPressed: () {
                            addData();
                            fNameController.clear();
                            lNameController.clear();
                            ageController.clear();
                          },
                          child: const Text('Submit'),
                          style: style())
                      : Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateData();
                                fNameController.clear();
                                lNameController.clear();
                                ageController.clear();
                                setState(() {
                                  show = true;
                                });
                              },
                              child: const Text('Update'),
                              style: style(),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                                onPressed: () {
                                  fNameController.clear();
                                  lNameController.clear();
                                  ageController.clear();
                                  setState(() {
                                    show = true;
                                  });
                                },
                                child: const Text('Clear'),
                                style: style()),
                          ],
                        ),
                  const SizedBox(width: 10.0),
                ],
              ),
              const SizedBox(height: 20.0),
              Container(
                height: 3.0,
                color: Colors.black87,
              ),
              const SizedBox(height: 20.0),
              databaseReference == null
                  ? Text('No data')
                  : Expanded(
                      child: StreamBuilder(
                          stream: databaseReference.onValue,
                          builder:
                              (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                            if (snapshot.hasData) {
                              List<Model> myDataList = [];
                              Map<dynamic, dynamic> data = snapshot.data!
                                  .snapshot.value as Map<dynamic, dynamic>;
                              data.forEach((key, value) {
                                myDataList.add(Model.fromJson(
                                    Map<String, dynamic>.from(value)));
                              });
                              return ListView.builder(
                                itemCount: myDataList.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(myDataList[index]
                                              .firstName
                                              .toString()),
                                          Text(myDataList[index]
                                              .lastName
                                              .toString()),
                                          Text(
                                              myDataList[index].age.toString()),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                fNameController.text =
                                                    myDataList[index]
                                                        .firstName
                                                        .toString();
                                                lNameController.text =
                                                    myDataList[index]
                                                        .lastName
                                                        .toString();
                                                ageController.text =
                                                    myDataList[index]
                                                        .age
                                                        .toString();
                                                key = myDataList[index]
                                                    .id
                                                    .toString();

                                                setState(() {
                                                  show = false;
                                                });
                                              },
                                              child: const Text('Update'),
                                              style: style()),
                                          ElevatedButton(
                                              onPressed: () {
                                                databaseReference
                                                    .child(
                                                        myDataList[index].id!)
                                                    .remove();
                                              },
                                              child: const Text('Delete'),
                                              style: style()),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          }),
                    ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  void addData() {
    late DatabaseReference dbRef = databaseReference.push();
    Model data = Model();

    String? newKey = dbRef.key;
    data.id = newKey;
    data.firstName = fNameController.text;
    data.lastName = lNameController.text;
    data.age = int.parse(ageController.text);
    dbRef.set(data.toJson());
    print(newKey);
  }

  void updateData() {
    databaseReference.child(key!).update({
      'first_name': fNameController.text,
      'last_name': lNameController.text,
      'age': ageController.text,
    });
  }

  uploadImage(ImageSource source) async {
    final firebaseStorage = FirebaseStorage.instance;
    XFile? pickFile = await ImagePicker().pickImage(source: source);
    File file = File(pickFile!.path);
    TaskSnapshot snapshot =
        await firebaseStorage.ref().child('images/imageName').putFile(file);
    String? url = await snapshot.ref.getDownloadURL();

    setState(() {
      imageFile = url;
    });
  }

  Widget bottomSheet() {
    return FlatButton.icon(
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text(''),
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 1.0, 1.0),
      onPressed: () {
        showModalBottomSheet(
          builder: (BuildContext context) {
            return Container(
              height: 150.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    TextButton.icon(
                      onPressed: () {
                        uploadImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 30.0),
                      label: const Text(
                        'Camera',
                        style: TextStyle(fontSize: 15.0, color: Colors.black87),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        uploadImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.image, size: 30.0),
                      label: const Text('Choose from Gallery',
                          style:
                              TextStyle(fontSize: 15.0, color: Colors.black87)),
                    )
                  ]),
            );
          },
          context: context,
        );
      },
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(borderRadius: BorderRadius.circular(20.0));
  }

   circular(){
    return CircularProgressIndicator();
  }

  ButtonStyle style() {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
