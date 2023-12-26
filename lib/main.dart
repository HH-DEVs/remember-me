import 'package:flutter/material.dart';
import 'package:share_box/card.dart';
import 'package:share_box/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Layout()
    );
  }
}

class Layout extends StatelessWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Share Box", style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600)),
        toolbarHeight: 70,
        titleSpacing: 11,
      ),
      body: const MainPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
          showDialog(context: context, builder: (ctx) => DetailCard(create: true)),
        child: const Icon(Icons.add),
      ),
    );
  }
}