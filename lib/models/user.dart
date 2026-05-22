class UserModel{
  final String email;
  final String name;
  final String role;
  final String uid;

  UserModel({
    required this.email,
    required this.name,
    required this.role,
    required this.uid,
  });

  factory UserModel.fromFirestore(Map<String, dynamic>data){
    return UserModel(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      uid: data['uid'] ?? '',
    );
  }
}