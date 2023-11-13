import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import "Telas/Tela1.dart";
import "Telas/Tela2.dart";
import "Telas/Tela3.dart";
import "Telas/Tela4.dart";
import "Telas/Tela5.dart";
import "Telas/Tela6.dart";
import "Telas/Tela7.dart";
import "Telas/Tela8.dart";
import "Telas/Tela9.dart";
import "Telas/Tela10.dart";
import "Telas/Tela11.dart";
import "Telas/Tela12.dart";



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
        '/tela6': (context) => Tela6(),
        '/tela7': (context) => Tela7(),
        '/tela8': (context) => Tela8(),
        '/tela9': (context) => Tela9(),
        '/tela10': (context) => Tela10(),
        '/tela11': (context) => Tela11(),
        '/tela12': (context) => Tela12(),
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







