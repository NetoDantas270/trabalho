import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tela9 extends StatefulWidget {
  @override
  _Tela9State createState() => _Tela9State();
}

class _Tela9State extends State<Tela9> {
  TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool ignoreInitialFilter = false; // Flag para ignorar o filtro inicial

  // Mapeamento entre os valores recebidos do banco de dados e os ícones do Flutter
  final Map<String, IconData> iconMappings = {
    'restaurant': Icons.restaurant,
    'house': Icons.house,
    'spa': Icons.spa,
    'school': Icons.school,
    'movie': Icons.movie,
    'add': Icons.add,
    'hotel': Icons.hotel,
    'cleaning_services': Icons.cleaning_services,
    'settings': Icons.settings,
    'pets': Icons.pets,
    'local_hospital': Icons.local_hospital,
    'directions_bus': Icons.directions_bus,
    // Adicione mais mapeamentos conforme necessário
  };

  @override
  void initState() {
    super.initState();
    // Carregue os produtos do banco de dados ao iniciar a tela
    fetchProducts().then((products) {
      setState(() {
        allProducts = List.of(products);
        _filterProducts(""); // Inicialmente, exibir todos os produtos
        ignoreInitialFilter = true; // Configura a flag para ignorar o filtro inicial
      });
    });
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://my-json-server.typicode.com/NetoDantas270/BD_mobile/products'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> productsJson = json.decode(response.body);
      List<Product> products = productsJson.map((json) => Product.fromJson(json, iconMappings)).toList();
      return products;
    } else {
      throw Exception('Falha ao carregar os produtos do banco de dados');
    }
  }

  void _filterProducts(String searchTerm) {
    setState(() {
      searchTerm = searchTerm.toLowerCase(); // Converter o termo de pesquisa para minúsculas
      if (searchTerm.isEmpty) {
        // Caso a barra de pesquisa esteja vazia, ative o filtro 'Manutenção'
        filteredProducts = allProducts.where((product) => product.tags.contains('Manutenção')).toList();
      } else {
        // Caso contrário, aplique os filtros normais
        filteredProducts = allProducts.where((product) {
          return (ignoreInitialFilter || product.tags.contains('Manutenção') || searchTerm.isNotEmpty) &&
              (searchTerm.isEmpty ||
                  product.name.toLowerCase().contains(searchTerm) ||
                  product.service.toLowerCase().contains(searchTerm) ||
                  _containsIgnoreCase(product.tags, searchTerm) ||
                  product.price.toString().toLowerCase().contains(searchTerm));
        }).toList();
      }
    });
  }

  bool _containsIgnoreCase(List<String> list, String searchTerm) {
    return list.any((item) => item.toLowerCase().contains(searchTerm));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manutenção'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _filterProducts(value);
                },
              ),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(
                  product.icon,
                  product.name,
                  product.service,
                  product.price.toString(),
                  product.description,
                  product.tags.join(', '),
                  product.avaliacao ?? 0.0,  // Adicionando a avaliação ao card
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
      IconData icon,
      String name,
      String service,
      String price,
      String description,
      String tags,
      double avaliacao,  // Adicionando o parâmetro de avaliação
      ) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 4.0,
      child: ListTile(
        leading: Icon(icon, size: 48.0),
        title: Text(name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service),
            Text(price, style: TextStyle(fontSize: 16.0)),
            _buildAvaliacaoStars(avaliacao), // Chamando o método para construir as estrelas de avaliação
            InkWell(
              onTap: () {
                // Ao clicar em um produto, exibir a descrição e as tags
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Descrição do Produto'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Descrição: $description'),
                          Text('Tags: $tags'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Fechar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                'Ver Mais',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAvaliacaoStars(double avaliacao) {
    int filledStars = avaliacao.floor();
    bool hasHalfStar = (avaliacao - filledStars) >= 0.5;

    List<Widget> stars = List.generate(
      5,
          (index) {
        IconData starIcon = Icons.star;
        if (index < filledStars) {
          starIcon = Icons.star;
        } else if (hasHalfStar && index == filledStars) {
          starIcon = Icons.star_half;
        } else {
          starIcon = Icons.star_border;
        }
        return Icon(starIcon, color: Colors.yellow);
      },
    );

    return Row(
      children: [
        Row(children: stars),
        SizedBox(width: 5),
        Text(avaliacao.toString()), // Adicionando a nota em números
      ],
    );
  }

}

class Product {
  final int id;
  final String name;
  final String service;
  final double price;
  final String description;
  final List<String> tags;
  double? avaliacao; // Removendo o 'final' para permitir modificação
  final IconData icon;

  Product({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.description,
    required this.tags,
    this.avaliacao, // Permitindo valores nulos
    required this.icon,
  });

  factory Product.fromJson(Map<String, dynamic> json, Map<String, IconData> iconMappings) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      service: json['service'] as String,
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      avaliacao: json['avaliacao'] != null ? json['avaliacao'].toDouble() : null,
      icon: iconMappings[json['icon']] ?? Icons.error,
    );
  }
}
