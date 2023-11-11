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

  // Lista de tags
  List<String> tags = [];
  // Map para manter o controle das tags selecionadas
  Map<String, bool> selectedTags = {};

  IconData selectedIcon = Icons.business; // Ícone padrão

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://my-json-server.typicode.com/NetoDantas270/BD_mobile/products'));
    if (response.statusCode == 200) {
      final List<dynamic> productsJson = json.decode(response.body);
      List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
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

    if (name.isNotEmpty && service.isNotEmpty && price.isNotEmpty) {
      final Map<String, dynamic> productData = {
        'name': name,
        'service': service,
        'price': double.parse(price),
        'description': description,
        'tags': tags,
        'icon': selectedIcon.codePoint, // Mapeia o ícone para um código de ponto
      };

      // Realize a chamada para adicionar o produto ao banco de dados
      final response = await http.post(
        Uri.parse('https://my-json-server.typicode.com/NetoDantas270/BD_mobile/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        // Produto adicionado com sucesso
        setState(() {
          tags = []; // Limpar as tags
          _nameController.clear();
          _serviceController.clear();
          _priceController.clear();
          _descriptionController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 5'),
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
    final List<String> availableTags = ["Tag1", "Tag2", "Tag3", "Tag4"];
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      service: json['service'] as String,
      price: json['price'].toDouble(),
      description: json['description'] as String,
      tags: List<String>.from(json['tags']),
      icon: Icons.business, // Defina o ícone com base nos dados, se necessário
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service,
      'price': price,
      'description': description,
      'tags': tags,
      // Se necessário, você pode mapear o ícone para um valor que faça sentido para a API
      // 'icon': icon.codePoint,
    };
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
    icon: Icon(Icons.business),
    onPressed: () => onIconSelected(Icons.business),
    color: selectedIcon == Icons.business ? Colors.blue : Colors.grey,
    ),
    IconButton(
    icon: Icon(Icons.home),
    onPressed: () => onIconSelected(Icons.home),
    color: selectedIcon == Icons.home ? Colors.blue : Colors.grey,
    ),
    IconButton(
    icon: Icon(Icons.school),
    onPressed: () => onIconSelected(Icons.school),
    color: selectedIcon == Icons.school ? Colors.blue : Colors.grey,
    ),
    ],
    ),
    ],
    );
  }
}

