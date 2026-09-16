import 'dart:convert';
import 'dart:typed_data';

class Contact {
  final String name;
  final String email;
  final String phone;
  final Uint8List? image;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'image': image != null ? base64Encode(image!) : null,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      image: map['image'] != null ? base64Decode(map['image']) : null,
    );
  }
}