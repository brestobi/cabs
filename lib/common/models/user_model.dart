import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String? role;
  final String phone;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final double rating;
  final double walletBalance;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    this.role,
    required this.phone,
    this.email,
    required this.fullName,
    this.avatarUrl,
    this.rating = 0.0,
    this.walletBalance = 0.0,
    this.isVerified = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, role, phone, email, fullName, avatarUrl, rating, walletBalance, isVerified, createdAt];
}
