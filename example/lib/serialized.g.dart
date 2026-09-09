// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serialized.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  status: json['status'] as String,
  species: json['species'] as String,
  type: json['type'] as String,
  gender: json['gender'] as String,
  image: json['image'] as String,
);

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
  (json['count'] as num).toInt(),
  (json['pages'] as num).toInt(),
  json['next'] as String?,
  json['prev'] as String?,
);

PageOfCharacters _$PageOfCharactersFromJson(Map<String, dynamic> json) =>
    PageOfCharacters(
      Info.fromJson(json['info'] as Map<String, dynamic>),
      (json['results'] as List<dynamic>)
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
