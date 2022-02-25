import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
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

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref().child('login');
  var key;
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: databaseReference.onValue,
                  builder: (context,AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData)  {
                      List<Model> myDataList = [];
                      Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      data.forEach((key, value) {
                        myDataList.add(Model.fromJson(Map<String, dynamic>.from(value)));
                      });
                      return Column(
                        children: [

                          Row(
                           children: [
                              const SizedBox(width: 10.0,),
                              Expanded(
                                child: TextField(
                                  controller: fNameController,
                                  decoration: InputDecoration(
                                      hintText: 'First Name',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20.0))),
                                ),
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: lNameController,
                                  decoration: InputDecoration(
                                      hintText: 'Last Name',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20.0))),
                                ),
                              ),
                              const SizedBox(width: 10.0,),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10.0,),
                              Expanded(
                                child: TextField(
                                  maxLength: 2,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  keyboardType: TextInputType.number,
                                  controller: ageController,
                                  decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Age',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20.0))),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                             show ? ElevatedButton(
                                onPressed: () {
                                  addData();
                                  fNameController.clear();
                                  lNameController.clear();
                                  ageController.clear();
                                },
                                child: const Text('Submit'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ) :
                                 Row(
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
                                       style: ElevatedButton.styleFrom(
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(10),
                                         ),
                                       ),
                                     ),
                                      const SizedBox(width: 10,),
                                     const SizedBox(
                                       width: 10.0,
                                     ),
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
                                       style: ElevatedButton.styleFrom(
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(10),
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                              const SizedBox(width: 10.0,),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            height: 5.0,
                            color: Colors.black87,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: myDataList.length,
                               itemBuilder: (context, index) {
                               return Column(
                                children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                      Column(
                                        children: [
                                          Text(myDataList[index].fName.toString()),
                                          Text(myDataList[index].lName.toString()),
                                          Text(myDataList[index].age.toString()),
                                        ],
                                      ),
                                     Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: (){
                                            fNameController.text = myDataList[index].fName.toString();
                                            lNameController.text = myDataList[index].lName.toString();
                                            ageController.text = myDataList[index].age.toString();
                                            key = myDataList[index].id.toString();
                                           setState(() {
                                             show = false;
                                           });
                                          },
                                          child: const Text('Update'),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: (){
                                            databaseReference.child(myDataList[index].id!).remove();
                                          },
                                          child: const Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  ),
                                ],
                                  );
                                 },
                               )
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      )  ;
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
          ],
        ),
      ),
    );
  }
  void addData() {
    late DatabaseReference dbRef = databaseReference.push();
    String? newKey = dbRef.key;
    dbRef.set({
      'first_name': fNameController.text,
      'last_name': lNameController.text,
      'age': ageController.text,
      'id': newKey});
  }
  void updateData(){
    databaseReference.child(key!).update({
      'first_name': fNameController.text,
      'last_name': lNameController.text,
      'age': ageController.text,
    });
  }

}
