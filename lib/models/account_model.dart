class AccountModel {
  final String email;
  final String password;

  const AccountModel({
    required this.email,
    required this.password,
  });

  AccountModel.fromJson(Map<String, Object?> json)
      : this(
          email: json['email']! as String,
          password: json['password']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
