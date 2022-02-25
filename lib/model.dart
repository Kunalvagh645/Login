import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Model {
  String? id;
  String? fName;
  String? lName;
  String? age;

  Model({
    required this.id,
    required this.fName,
    required this.lName,
    required this.age,
  }
  );

  factory Model.fromJson(Map<String, dynamic> data){
      return Model(
          id: data['id'],
          fName: data['first_name'],
          lName: data['last_name'],
          age: data['age'],
      );
  }


  }
