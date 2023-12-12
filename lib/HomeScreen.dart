import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  bool ignoreInitialFilter = false;
  bool searchTermDeleted = false; // Adicione a declaração da variável aqui

  late TabController _tabController;

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

    // Inicializar a TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose da TabController quando a tela for descartada
    _tabController.dispose();
    super.dispose();
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
      searchTerm = searchTerm.toLowerCase();

      if (searchTerm.isEmpty) {
        filteredProducts = allProducts
            .where((product) => product.avaliacao != null)
            .toList()
          ..sort((a, b) {
            if (a.avaliacao != null && b.avaliacao != null) {
              return b.avaliacao!.compareTo(a.avaliacao!);
            } else {
              return 0;
            }
          });
        searchTermDeleted = false;
      } else {
        filteredProducts = allProducts
            .where((product) =>
        product.name.toLowerCase().contains(searchTerm) ||
            product.service.toLowerCase().contains(searchTerm) ||
            _containsIgnoreCase(product.tags, searchTerm) ||
            product.price.toString().toLowerCase().contains(searchTerm))
            .toList();
        searchTermDeleted = true;
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
        title: Text('Tela Principal'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Produtos'),
            Tab(text: 'Botões'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(context),
          _buildButtonsTab(context),
        ],
      ),
    );
  }

  Widget _buildButtonsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.0),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: iconMappings.length,
            itemBuilder: (context, index) {
              final iconKey = iconMappings.keys.elementAt(index);
              final icon = iconMappings[iconKey]!;
              return _buildRoundedButton(context, icon, _getButtonText(iconKey), () {
                _navigateToProductScreen(context, icon);
              });
            },
          ),
        ],
      ),
    );
  }

  String _getButtonText(String iconKey) {
    switch (iconKey) {
      case 'restaurant':
        return 'Alimentação';
      case 'house':
        return 'Aluguel';
      case 'spa':
        return 'Beleza';
      case 'school':
        return 'Educação';
      case 'movie':
        return 'Entretenimento';
      case 'add':
        return 'Adicionar';
      case 'hotel':
        return 'Hotelaria';
      case 'cleaning_services':
        return 'Limpeza';
      case 'settings':
        return 'Manutenção';
      case 'pets':
        return 'Pets';
      case 'local_hospital':
        return 'Saúde';
      case 'directions_bus':
        return 'Transporte';
      default:
        return 'Desconhecido';
    }
  }

  Widget _buildProductsTab(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildRoundedButton(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
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

  void _navigateToProductScreen(BuildContext context, IconData icon) {
    // Implemente a navegação para a tela de produtos com base no ícone
    // Aqui você pode usar um switch ou if-else para determinar a rota apropriada
    switch (icon) {
      case Icons.restaurant:
        Navigator.pushNamed(context, '/tela1');
        break;
      case Icons.house:
        Navigator.pushNamed(context, '/tela2');
        break;
      case Icons.spa:
        Navigator.pushNamed(context, '/tela3');
        break;
      case Icons.school:
        Navigator.pushNamed(context, '/tela4');
        break;
      case Icons.movie:
        Navigator.pushNamed(context, '/tela6');
        break;
      case Icons.add:
        Navigator.pushNamed(context, '/tela5');
        break;
      case Icons.hotel:
        Navigator.pushNamed(context, '/tela7');
        break;
      case Icons.cleaning_services:
        Navigator.pushNamed(context, '/tela8');
        break;
      case Icons.settings:
        Navigator.pushNamed(context, '/tela9');
        break;
      case Icons.pets:
        Navigator.pushNamed(context, '/tela10');
        break;
      case Icons.local_hospital:
        Navigator.pushNamed(context, '/tela11');
        break;
      case Icons.directions_bus:
        Navigator.pushNamed(context, '/tela12');
        break;
    // Adicione mais casos conforme necessário
      default:
        print('Ícone não mapeado para uma rota.');
    }
  }

  Widget _buildProductCard(
      IconData icon,
      String name,
      String service,
      String price,
      String description,
      String tags,
      double? avaliacao,  // Alteração: Mudando de int para double
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
            _buildAvaliacaoStars(avaliacao!), // Exibindo a avaliação como estrelas
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
