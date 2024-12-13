import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonScreen extends StatefulWidget {
  @override
  _PokemonScreenState createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final TextEditingController _pokemonController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  Map<String, dynamic>? _pokemonData;
  List<dynamic>? _books;
  bool _isLoadingPokemon = false;
  bool _isLoadingBooks = false;

  Future<void> fetchPokemon(String name) async {
    setState(() {
      _isLoadingPokemon = true;
    });

    final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));

    if (response.statusCode == 200) {
      setState(() {
        _pokemonData = json.decode(response.body);
        _isLoadingPokemon = false;
      });
    } else {
      setState(() {
        _pokemonData = null;
        _isLoadingPokemon = false;
      });
    }
  }

  Future<void> fetchBooks(String query) async {
    setState(() {
      _isLoadingBooks = true;
    });

    final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _books = json.decode(response.body)['items'];
        _isLoadingBooks = false;
      });
    } else {
      setState(() {
        _books = null;
        _isLoadingBooks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador de Pokémon y Libros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pokémon Search
            TextField(
              controller: _pokemonController,
              decoration: InputDecoration(
                labelText: 'Ingrese el nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_pokemonController.text.isNotEmpty) {
                  fetchPokemon(_pokemonController.text.toLowerCase());
                }
              },
              child: Text('Buscar Pokémon'),
            ),
            SizedBox(height: 16),
            if (_isLoadingPokemon)
              CircularProgressIndicator()
            else if (_pokemonData != null)
              Column(
                children: [
                  Image.network(
                    _pokemonData!['sprites']['front_default'],
                    height: 100,
                  ),
                  Text(
                    _pokemonData!['name'].toString().toUpperCase(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Altura: ${_pokemonData!['height']}'),
                  Text('Peso: ${_pokemonData!['weight']}'),
                ],
              )
            else
              Text('No se encontró el Pokémon.'),

            Divider(height: 32, thickness: 2),

            // Books Search
            TextField(
              controller: _bookController,
              decoration: InputDecoration(
                labelText: 'Ingrese el nombre del libro',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_bookController.text.isNotEmpty) {
                  fetchBooks(_bookController.text);
                }
              },
              child: Text('Buscar Libros'),
            ),
            SizedBox(height: 16),
            if (_isLoadingBooks)
              CircularProgressIndicator()
            else if (_books != null && _books!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _books!.length,
                  itemBuilder: (context, index) {
                    final book = _books![index]['volumeInfo'];
                    return ListTile(
                      leading: book['imageLinks'] != null
                          ? Image.network(
                              book['imageLinks']['thumbnail'],
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.book),
                      title: Text(book['title'] ?? 'No Title'),
                      subtitle: Text(
                        book['authors'] != null
                            ? book['authors'].join(', ')
                            : 'Unknown Author',
                      ),
                    );
                  },
                ),
              )
            else
              Text('No se encontraron libros.'),
          ],
        ),
      ),
    );
  }
}

