import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:pausable_stream_iterable/pausable_stream_iterable.dart';

import 'serialized.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CharacterPaginationWidget(),
        ),
      ),
    ),
  );
}

class CharacterPaginationWidget extends StatefulWidget {
  const CharacterPaginationWidget({super.key});

  @override
  State<CharacterPaginationWidget> createState() => _CharacterPaginationWidgetState();
}

class _CharacterPaginationWidgetState extends State<CharacterPaginationWidget> {
  final dio = Dio();

  final firstPageUrl = 'https://rickandmortyapi.com/api/character';

  void createPaginationFromFirstPage() {
    remoteCharactersStream = recursivePaginatedCharacters(firstPageUrl).pauseOnNonEmptyResumeOnLast();
  }

  // When stream is done - all data is synced from remote
  late Stream<Iterable<Character>> remoteCharactersStream;

  @override
  void initState() {
    createPaginationFromFirstPage();
    super.initState();
  }

  void retry() => setState(createPaginationFromFirstPage);

  final localSynchronizedCharacters = <Character>[];

  Stream<Iterable<Character>> recursivePaginatedCharacters(String pageUrl) async* {
    final response = await dio.get(pageUrl);

    final page = PageOfCharacters.fromJson(response.data);

    yield localSynchronizedCharacters..addAll(page.results);

    final nextPageUrl = page.info.next;

    if (nextPageUrl == null) return;

    yield* recursivePaginatedCharacters(nextPageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: remoteCharactersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            children: [
              Text('Error: ${snapshot.error}'),
              OutlinedButton(onPressed: retry, child: const Text('Retry')),
            ],
          );
        }

        final isAllCharactersSyncedFromRemote = snapshot.connectionState == .done;

        final characters = snapshot.data;

        if (characters == null) return const CircularProgressIndicator();

        final skeletonItemsCount = isAllCharactersSyncedFromRemote ? 0 : 3;

        return ListView.builder(
          itemExtent: 150,
          itemCount: characters.length + skeletonItemsCount,
          itemBuilder: (_, index) {
            if (index < characters.length) return CharacterWidget(characters.elementAt(index));

            return const LinearProgressIndicator();
          },
        );
      },
    );
  }
}

class CharacterWidget extends StatelessWidget {
  const CharacterWidget(this.character, {super.key});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Image.network(
            character.image,
            errorBuilder: (_, error, stack) => Text('$error'),
          ),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(character.name),
              Text(character.gender),
              Text(character.species),
              Text(character.status),
              Text(character.type),
            ],
          ),
        ],
      ),
    );
  }
}
