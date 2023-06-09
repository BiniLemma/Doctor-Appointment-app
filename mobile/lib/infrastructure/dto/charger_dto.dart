import 'dart:math';

import 'package:charge_station_finder/domain/charger/charger.dart';
import 'package:charge_station_finder/infrastructure/dto/review_dto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ChargerDto extends Equatable {
  final String? id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final double wattage;
  final int userVote;
  late final bool hasUserRated;
  final double? rating;
  final String? user;
  List<ReviewDto> reviews;

  ChargerDto(
    this.id,
    this.name,
    this.description,
    this.address,
    this.phone,
    this.wattage,
    this.rating,
    this.userVote,
    this.user,
    this.reviews,
  ) {
    hasUserRated = userVote != -1;
  }

  factory ChargerDto.fromJson(Map<String, dynamic> json) {
    return ChargerDto(
      json['_id'],
      json['name'],
      json['description'],
      json['address'],
      json['phone'],
      ( json['wattage']!.toDouble()) ?? -1000.0,
      json['rating']!.toDouble(),
      json['voted'],
      json['user'],
      ((json['comments'] ?? []) as List)
          .map((e) => ReviewDto.fromJson(e))
          .toList(growable: false),
    );
  }

  factory ChargerDto.fromDb(Map<String, dynamic> queryResult, List<Map<String, dynamic>> reviews) {
    debugPrint(queryResult.toString());
    return ChargerDto(
      queryResult['id'],
      queryResult['name'],
      queryResult['description'],
      queryResult['address'],
      queryResult['phone'],
      (queryResult['wattage'] ?? -1000).toDouble(),
      queryResult['rating'],
      queryResult['userVote'] ?? -1,
      queryResult['authorId'] ?? '',
      reviews.map((e) => ReviewDto.fromEntity(e)).toList(),
    );
  }

  Charger toDomain() {
    return Charger(
      id: id!,
      name: name,
      description: description,
      address: address,
      phone: phone,
      wattage: wattage ?? -1,
      rating: 0.0,
      hasUserRated: hasUserRated,
      authorId: user!,
      reviews: reviews.map((e) => e.toDomain()).toList(),
      userVote: userVote,
    );
  }

  @override
  List<Object?> get props => [id, name, description, address, phone, wattage];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'wattage': wattage ?? -1,
      'rating': rating ?? 0,
    };
  }
}
