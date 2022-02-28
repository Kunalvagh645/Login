class Model {
  String? id;
  int? age;
  String? firstName;
  String? lastName;

  Model({this.id, this.age, this.firstName, this.lastName});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    age = json['age'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['age'] = this.age;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}