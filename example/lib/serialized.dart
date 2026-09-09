import 'package:json_annotation/json_annotation.dart';

part 'serialized.g.dart';

@JsonSerializable(createToJson: false)
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);
}

@JsonSerializable(createToJson: false)
class Info {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  Info(this.count, this.pages, this.next, this.prev);

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

abstract class PageOf<T> {
  final Info info;
  List<T> results;

  PageOf(this.info, this.results);
}

@JsonSerializable(createToJson: false)
class PageOfCharacters extends PageOf<Character> {
  PageOfCharacters(super.info, super.results);

  factory PageOfCharacters.fromJson(Map<String, dynamic> json) => _$PageOfCharactersFromJson(json);
}
