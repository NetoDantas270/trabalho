import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Tela5.dart';



void main() {
  List<Product> products = []; // Lista inicial de produtos vazia

  runApp(MyApp(products: products));
}

class MyApp extends StatelessWidget {
  final List<Product> products;

  MyApp({required this.products});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
        '/tela1': (context) => Tela1(),
        '/tela2': (context) => Tela2(),
        '/tela3': (context) => Tela3(),
        '/tela4': (context) => Tela4(),
        '/tela5': (context) => Tela5(),
      },
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  if (username.isNotEmpty && password.isNotEmpty) {
                    // Verificação de credenciais bem-sucedida
                    Navigator.pushNamed(context, '/home'); // Navega para a tela principal
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Credenciais inválidas'),
                          content: Text('Preencha o nome de usuário e a senha.'),
                          actions: <Widget>[
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
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Tela1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 1'),
      ),
      body: Center(
        child: Text('Bem-vindo à Tela 1!'),
      ),
    );
  }
}

class Tela2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 2'),
      ),
      body: Center(
        child: Text('Bem-vindo à Tela 2!'),
      ),
    );
  }
}

class Tela3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 3'),
      ),
      body: Center(
        child: Text('Bem-vindo à Tela 3!'),
      ),
    );
  }
}

class Tela4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela 4'),
      ),
      body: Center(
        child: Text('Bem-vindo à Tela 4!'),
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
}








