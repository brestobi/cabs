// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  passengerId: json['passengerId'] as String,
  driverId: json['driverId'] as String?,
  pickupLocation: LocationModel.fromJson(
    json['pickupLocation'] as Map<String, dynamic>,
  ),
  dropoffLocation: LocationModel.fromJson(
    json['dropoffLocation'] as Map<String, dynamic>,
  ),
  pickupAddress: json['pickupAddress'] as String,
  dropoffAddress: json['dropoffAddress'] as String,
  status: json['status'] as String,
  fareEstimate: (json['fareEstimate'] as num).toDouble(),
  finalFare: (json['finalFare'] as num?)?.toDouble(),
  paymentMethod: json['paymentMethod'] as String,
  pickupVerificationCode: json['pickupVerificationCode'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'passengerId': instance.passengerId,
      'driverId': instance.driverId,
      'pickupLocation': instance.pickupLocation,
      'dropoffLocation': instance.dropoffLocation,
      'pickupAddress': instance.pickupAddress,
      'dropoffAddress': instance.dropoffAddress,
      'status': instance.status,
      'fareEstimate': instance.fareEstimate,
      'finalFare': instance.finalFare,
      'paymentMethod': instance.paymentMethod,
      'pickupVerificationCode': instance.pickupVerificationCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
