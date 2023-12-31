import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tela5 extends StatefulWidget {
  @override
  _Tela5State createState() => _Tela5State();
}

class _Tela5State extends State<Tela5> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _avaliacaoController = TextEditingController();

  List<String> tags = [];
  Map<String, bool> selectedTags = {};
  IconData selectedIcon = Icons.restaurant;

  final Map<String, IconData> iconMappings = {
    'restaurant': Icons.restaurant,
    'house': Icons.house,
    'spa': Icons.spa,
    'school': Icons.school,
    'movie': Icons.movie,
    'hotel': Icons.hotel,
    'cleaning_services': Icons.cleaning_services,
    'settings': Icons.settings,
    'pets': Icons.pets,
    'local_hospital': Icons.local_hospital,
    'directions_bus': Icons.directions_bus,
  };

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://my-json-server.typicode.com/NetoDantas270/BD_mobile/products'));
    if (response.statusCode == 200) {
      final List<dynamic> productsJson = json.decode(response.body);
      List<Product> products = productsJson.map((json) => Product.fromJson(json, iconMappings)).toList();
      return products;
    } else {
      throw Exception('Falha ao carregar os produtos do banco de dados');
    }
  }

  Future<void> _addProduct() async {
    final String name = _nameController.text;
    final String service = _serviceController.text;
    final String price = _priceController.text;
    final String description = _descriptionController.text;
    final String avaliacao = _avaliacaoController.text;

    if (name.isNotEmpty && service.isNotEmpty && price.isNotEmpty) {
      final Map<String, dynamic> productData = {
        'name': name,
        'service': service,
        'price': double.parse(price),
        'description': description,
        'tags': tags,
        'icon': selectedIcon.codePoint,
        'avaliacao': double.parse(avaliacao), // Avaliação adicionada
      };

      final response = await http.post(
        Uri.parse('https://my-json-server.typicode.com/NetoDantas270/BD_mobile/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        setState(() {
          tags = [];
          _nameController.clear();
          _serviceController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _avaliacaoController.clear(); // Limpar o campo de avaliação
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Novo Serviço'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome do Vendedor'),
              ),
              TextField(
                controller: _serviceController,
                decoration: InputDecoration(labelText: 'Serviço Vendido'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Preço do Serviço'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição do Vendedor'),
              ),
              TextField(
                controller: _avaliacaoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Avaliação (0.0 - 5.0)'),
              ),
              Text(
                'Selecione Tags:',
                style: TextStyle(fontSize: 18.0),
              ),
              Wrap(
                spacing: 10.0,
                children: _buildTagChips(),
              ),
              IconSelector(
                selectedIcon: selectedIcon,
                onIconSelected: (icon) {
                  setState(() {
                    selectedIcon = icon;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Adicionar Serviço'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Serviços Criados:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              FutureBuilder<List<Product>>(
                future: fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Nenhum serviço criado ainda.');
                  } else {
                    List<Product> products = snapshot.data!;
                    return Column(
                      children: products.map((product) {
                        return Card(
                          margin: EdgeInsets.all(16.0),
                          elevation: 4.0,
                          child: ListTile(
                            leading: Icon(product.icon),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Serviço: ${product.service}'),
                                Text('Preço: ${product.price.toStringAsFixed(2)}'),
                                Text('Descrição: ${product.description}'),
                                Text('Tags: ${product.tags.join(', ')}'),
                                Row(
                                  children: [
                                    Text('Avaliação: '),
                                    _buildRatingStars(product.avaliacao),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagChips() {
    final List<String> availableTags = ["Alimentação", "Aluguel", "Beleza", "Educação", "Entretenimento", "Hotelaria", "Limpeza", "Manutenção", "Pets", "Saúde", "Transporte"];
    final tagChips = <Widget>[];
    for (final tag in availableTags) {
      tagChips.add(_buildTagChip(tag));
    }
    return tagChips;
  }

  Widget _buildTagChip(String tag) {
    return CheckboxListTile(
      title: Text(tag),
      value: selectedTags.containsKey(tag) ? selectedTags[tag] : false,
      onChanged: (isSelected) {
        setState(() {
          selectedTags[tag] = isSelected!;
          if (isSelected) {
            tags.add(tag);
          } else {
            tags.remove(tag);
          }
        });
      },
    );
  }

  Widget _buildRatingStars(double rating) {
    int filledStars = rating.floor();
    bool hasHalfStar = (rating - filledStars) >= 0.5;

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
        Text(rating.toString()), // Adicionando a nota em números
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
  final IconData icon;
  final double avaliacao;

  Product({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.description,
    required this.tags,
    required this.icon,
    required this.avaliacao,
  });

  factory Product.fromJson(Map<String, dynamic> json, Map<String, IconData> iconMappings) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      service: json['service'] as String,
      price: json['price'].toDouble(),
      description: json['description'] as String,
      tags: List<String>.from(json['tags']),
      icon: iconMappings[json['icon']] ?? Icons.error,
      avaliacao: json['avaliacao'] != null ? json['avaliacao'].toDouble() : 0.0,
    );
  }
}

class IconSelector extends StatelessWidget {
  final IconData selectedIcon;
  final Function(IconData) onIconSelected;

  IconSelector({required this.selectedIcon, required this.onIconSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o Ícone:',
          style: TextStyle(fontSize: 18.0),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.restaurant),
              onPressed: () => onIconSelected(Icons.restaurant),
              color: selectedIcon == Icons.restaurant ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.house),
              onPressed: () => onIconSelected(Icons.house),
              color: selectedIcon == Icons.house ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.spa),
              onPressed: () => onIconSelected(Icons.spa),
              color: selectedIcon == Icons.spa ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.school),
              onPressed: () => onIconSelected(Icons.school),
              color: selectedIcon == Icons.school ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.movie),
              onPressed: () => onIconSelected(Icons.movie),
              color: selectedIcon == Icons.movie ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.hotel),
              onPressed: () => onIconSelected(Icons.hotel),
              color: selectedIcon == Icons.hotel ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.cleaning_services),
              onPressed: () => onIconSelected(Icons.cleaning_services),
              color: selectedIcon == Icons.cleaning_services ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => onIconSelected(Icons.settings),
              color: selectedIcon == Icons.settings ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.pets),
              onPressed: () => onIconSelected(Icons.pets),
              color: selectedIcon == Icons.pets ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.local_hospital),
              onPressed: () => onIconSelected(Icons.local_hospital),
              color: selectedIcon == Icons.local_hospital ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.directions_bus),
              onPressed: () => onIconSelected(Icons.directions_bus),
              color: selectedIcon == Icons.directions_bus ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}
