import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'location_model.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel extends Equatable {
  final String id;
  final String passengerId;
  final String? driverId;
  final LocationModel pickupLocation;
  final LocationModel dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final double fareEstimate;
  final double? finalFare;
  final String paymentMethod;
  final String pickupVerificationCode;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const BookingModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.fareEstimate,
    this.finalFare,
    required this.paymentMethod,
    required this.pickupVerificationCode,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        passengerId,
        driverId,
        pickupLocation,
        dropoffLocation,
        pickupAddress,
        dropoffAddress,
        status,
        fareEstimate,
        finalFare,
        paymentMethod,
        pickupVerificationCode,
        createdAt,
        startedAt,
        completedAt,
      ];
}
