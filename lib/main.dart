import 'package:flutter/material.dart';

// import 'package:solid/solid.dart';

import 'package:innerpod/timer.dart';

void main() {
  runApp(const InnerPod());
}

class InnerPod extends StatelessWidget {
  const InnerPod({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Pod',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Inner Pod Meditation Timer'),
        ),
        body: Center(
          child: Timer(),
        ),
      ),
      // home: const SolidLogin(
      //   // Images generated using Bing Image Creator from Designer, powered by
      //   // DALL-E3.

      //   image: AssetImage('assets/images/inner_image.jpg'),
      //   logo: AssetImage('assets/icon/icon.png'),
      //   title: 'MANAGE YOUR INNER POD',
      //   link: 'https://github.com/gjwgit/inner',
      //   child: Scaffold(body: Text('Inner Pod Placeholder')),
      // ),
    );
  }
}
