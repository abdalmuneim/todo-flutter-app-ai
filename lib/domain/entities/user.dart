import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends Equatable {
  final String? id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? language;
  final DateTime? createdAt;

  const User({
     this.id,
     this.email,
     this.displayName,
    this.photoUrl,
    this. language,
     this.createdAt,
  })  ;
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'language': language,
        'created_at':createdAt!=null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String,
        photoUrl: json['photo_url'] as String?,
        language: json['language'] as String,
        createdAt: (json['created_at'] as Timestamp).toDate(),
      );

  User copyWith({
    String? displayName,
    String? photoUrl,
    String? language,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, language, createdAt];
}