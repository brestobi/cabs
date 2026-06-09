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
  final bool isOnline;
  final String? licenseNumber;
  final String? licensePhotoUrl;
  final String? selfiePhotoUrl;
  final double totalEarnings;
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
    this.isOnline = false,
    this.licenseNumber,
    this.licensePhotoUrl,
    this.selfiePhotoUrl,
    this.totalEarnings = 0.0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? role,
    String? phone,
    String? email,
    String? fullName,
    String? avatarUrl,
    double? rating,
    double? walletBalance,
    bool? isVerified,
    bool? isOnline,
    String? licenseNumber,
    String? licensePhotoUrl,
    String? selfiePhotoUrl,
    double? totalEarnings,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      walletBalance: walletBalance ?? this.walletBalance,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
      selfiePhotoUrl: selfiePhotoUrl ?? this.selfiePhotoUrl,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        phone,
        email,
        fullName,
        avatarUrl,
        rating,
        walletBalance,
        isVerified,
        isOnline,
        licenseNumber,
        licensePhotoUrl,
        selfiePhotoUrl,
        totalEarnings,
        createdAt
      ];
}
