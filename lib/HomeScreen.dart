import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

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
        filteredProducts = List.of(allProducts);
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
      filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(searchTerm) ||
            product.service.toLowerCase().contains(searchTerm) ||
            _containsIgnoreCase(product.tags, searchTerm) ||
            product.price.toString().toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  bool _containsIgnoreCase(List<String> list, String searchTerm) {
    return list.any((item) => item.toLowerCase().contains(searchTerm));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Principal'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
            SizedBox(height: 20.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRoundedButton(context, Icons.restaurant, 'Alimentação', () {
                    Navigator.pushNamed(context, '/tela1');
                  }),
                  _buildRoundedButton(context, Icons.house, 'Aluguel', () {
                    Navigator.pushNamed(context, '/tela2');
                  }),
                  _buildRoundedButton(context, Icons.spa, 'Beleza e Bem-estar', () {
                    Navigator.pushNamed(context, '/tela3');
                  }),
                  _buildRoundedButton(context, Icons.school, 'Educação', () {
                    Navigator.pushNamed(context, '/tela4');
                  }),
                  _buildRoundedButton(context, Icons.add, 'Adicionar Novo Serviço', () {
                    Navigator.pushNamed(context, '/tela5');
                  }),
                  _buildRoundedButton(context, Icons.movie, 'Entretenimento', () {
                    Navigator.pushNamed(context, '/tela6');
                  }),
                  _buildRoundedButton(context, Icons.hotel, 'Hotelaria', () {
                    Navigator.pushNamed(context, '/tela7');
                  }),
                  _buildRoundedButton(context, Icons.cleaning_services, 'Limpeza', () {
                    Navigator.pushNamed(context, '/tela8');
                  }),
                  _buildRoundedButton(context, Icons.settings, 'Manutenção', () {
                    Navigator.pushNamed(context, '/tela9');
                  }),
                  _buildRoundedButton(context, Icons.pets, 'Pets', () {
                    Navigator.pushNamed(context, '/tela10');
                  }),
                  _buildRoundedButton(context, Icons.local_hospital, 'Saúde', () {
                    Navigator.pushNamed(context, '/tela11');
                  }),
                  _buildRoundedButton(context, Icons.directions_bus, 'Transporte', () {
                    Navigator.pushNamed(context, '/tela12');
                  }),
                ],
              ),
            ),
            SizedBox(height: 20.0),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedButton(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Define o raio das bordas
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.0),
          SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
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
}

class Product {
  final int id;
  final String name;
  final String service;
  final double price;
  final String description;
  final List<String> tags;
  final IconData icon;

  Product({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.description,
    required this.tags,
    required this.icon,
  });

  factory Product.fromJson(Map<String, dynamic> json, Map<String, IconData> iconMappings) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      service: json['service'] as String,
      price: json['price'].toDouble(),
      description: json['description'] as String,
      tags: List<String>.from(json['tags']),
      icon: iconMappings[json['icon']] ?? Icons.error, // Ícone padrão em caso de mapeamento ausente
    );
  }
}
