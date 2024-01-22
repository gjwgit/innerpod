import 'package:flutter/material.dart';

import 'package:solid/solid.dart';

void main() {
  runApp(const InnerPod());
}

class InnerPod extends StatelessWidget {
  const InnerPod({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key POD',
      theme: ThemeData(
        // This is the theme of your application.

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SolidLogin(
        // Images generated using Bing Image Creator from Designer, powered by
        // DALL-E3.

        image: AssetImage('assets/images/inner_image.jpg'),
        logo: AssetImage('assets/icon/icon.png'),
        title: 'MANAGE YOUR INNER POD',
        link: 'https://github.com/gjwgit/inner',
        child: Scaffold(body: Text('Inner Pod Placeholder')),
      ),
    );
  }
}
