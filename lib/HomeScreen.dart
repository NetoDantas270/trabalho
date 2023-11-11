import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

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
      List<Product> products = productsJson.map((json) => Product.fromJson(json)).toList();
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
      body: Column(
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
                _buildRoundedButton(context, Icons.ac_unit, 'Botão 1', () {
                  Navigator.pushNamed(context, '/tela1');
                }),
                _buildRoundedButton(context, Icons.access_alarm, 'Botão 2', () {
                  Navigator.pushNamed(context, '/tela2');
                }),
                _buildRoundedButton(context, Icons.accessibility, 'Botão 3', () {
                  Navigator.pushNamed(context, '/tela3');
                }),
                _buildRoundedButton(context, Icons.account_balance, 'Botão 4', () {
                  Navigator.pushNamed(context, '/tela4');
                }),
                _buildRoundedButton(context, Icons.add, 'Botão 5', () {
                  Navigator.pushNamed(context, '/tela5');
                }),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: GridView.builder(
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
