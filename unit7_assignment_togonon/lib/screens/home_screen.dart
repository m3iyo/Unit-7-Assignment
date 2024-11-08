import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureData;

  // Fetch data from the API
  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://narutodb.xyz/api/character'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['characters'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Naruto Characters")),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var character = snapshot.data![index];
                return CharacterTile(character: character);
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class CharacterTile extends StatelessWidget {
  final dynamic character;
  final ExpandedTileController _controller = ExpandedTileController();

  CharacterTile({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ExpandedTile(
      controller: _controller,
      title: Text(
        character['name'] ?? 'Unknown Character',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      leading: character['images'] != null && character['images'].isNotEmpty
          ? Image.network(
              character['images'][0],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.image_not_supported),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Jutsu: ${(character['jutsu'] ?? []).join(', ')}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "Unique Traits: ${(character['uniqueTraits'] ?? []).join(', ')}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const Divider(),
            const Text(
              "Debut Information:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("Novel: ${character['debut']?['novel'] ?? 'N/A'}"),
            Text("Movie: ${character['debut']?['movie'] ?? 'N/A'}"),
            Text("Appears In: ${character['debut']?['appearsIn'] ?? 'N/A'}"),
            const Divider(),
            if (character['family'] != null) ...[
              const Text(
                "Family Information:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("Incarnation with: ${character['family']?['incarnation with the god tree'] ?? 'N/A'}"),
              Text("Depowered form: ${character['family']?['depowered form'] ?? 'N/A'}"),
            ],
          ],
        ),
      ),
      theme: const ExpandedTileThemeData(
        headerColor: Colors.white,
        headerSplashColor: Colors.grey,
        contentBackgroundColor: Colors.white,
        contentPadding: EdgeInsets.all(8.0),
        headerPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}
