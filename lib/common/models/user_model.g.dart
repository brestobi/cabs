// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  role: json['role'] as String?,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
  isVerified: json['isVerified'] as bool? ?? false,
  isOnline: json['isOnline'] as bool? ?? false,
  licenseNumber: json['licenseNumber'] as String?,
  licensePhotoUrl: json['licensePhotoUrl'] as String?,
  selfiePhotoUrl: json['selfiePhotoUrl'] as String?,
  totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'phone': instance.phone,
  'email': instance.email,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'rating': instance.rating,
  'walletBalance': instance.walletBalance,
  'isVerified': instance.isVerified,
  'isOnline': instance.isOnline,
  'licenseNumber': instance.licenseNumber,
  'licensePhotoUrl': instance.licensePhotoUrl,
  'selfiePhotoUrl': instance.selfiePhotoUrl,
  'totalEarnings': instance.totalEarnings,
  'createdAt': instance.createdAt.toIso8601String(),
};
