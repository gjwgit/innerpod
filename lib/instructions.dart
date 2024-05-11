import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter/material.dart';

// TODO 20240511 gjw What are the pros and cons for a variable versus a class
// here?

// class Instructions extends StatefulWidget {
//   @override
//   _InstructionsState createState() => _InstructionsState();
// }

// class _InstructionsState extends State<Instructions> with SingleTickerProviderStateMixin {
//   TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(vsync: this, length: 3);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(icon: Icon(Icons.directions_car)),
//             Tab(icon: Icon(Icons.directions_transit)),
//             Tab(icon: Icon(Icons.directions_bike)),
//           ],
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               Icon(Icons.directions_car),
//               Icon(Icons.directions_transit),
//               Icon(Icons.directions_bike),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

///

Widget instructions = DefaultTabController(
  length: 3, // Number of tabs
  child: Scaffold(
    appBar: AppBar(
      flexibleSpace: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TabBar(
            indicatorColor: Colors.amberAccent,
            indicatorWeight: 5,
            // indicator: BoxDecoration(
            //   color: Colors.amber[800],
            //   borderRadius: BorderRadius.circular(25.0),
            // ),
            tabs: [
              Tab(text: 'Opening'),
              Tab(text: 'Guide'),
              Tab(text: 'Closing'),
            ],
          ),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        Markdown(
            data: '# Opening Prayer\n'
                '---\n'
                'Heavenly Father.  \n'
                '  \n'
                'Open our hearts to the silent '
                'presence of the spirit of your son.  \n'
                '  \n'
                'Lead us into that mysterious silence '
                'where your love is revealed to all who call.  \n'
                '  \n'
                'Maranatha.  \n'
                'Come Lord Jesus.  \n'
                '  \n'
                '---\n'
                '  \n'
                '*John Main OSB*',
            styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                textTheme:
                    const TextTheme(bodyMedium: TextStyle(fontSize: 20.0))))),
        Markdown(
            data: '# How to Meditate\n'
                '  \n'
                '---\n'
                '  \n'
                'To meditate you must learn to be still.  \n'
                'Meditation is perfect stillness of body and spirit.  \n'
                '  \n'
                'The stillness of body we achieve by sitting still. '
                'When you begin to meditate, take a couple of moments '
                'to assume a comfortable posture. '
                'The only essential rule is to have your spine '
                'as upright as possible. '
                'Your eyes should be lightly closed. '
                '  \n'
                'The way to a stillness of spirit is to learn to say silently '
                'in the depth of your spirit a word or a short phrase. '
                'To repeat that word over and over again. '
                'The recommended word is the Aramaic word Maranatha.'
                'Say it slowly in four equally stressed syllables. \n'
                '  \n'
                'Ma, Ra, Na, Tha.  \n'
                '  \n'
                'Say it silently. '
                'Don\'t move your lips but recite it interiorly. '
                'Recite your word from beginning to end. \n'
                '  \n'
                'Let go of your thoughts, of your ideas, of your imagination. '
                'Don\'t think.  '
                'Don\'t use any words other than your one word. '
                'Just say the word in the depth of your spirit and listen to it. '
                'Concentrate upon it with all your attention. '
                '  \n'
                'Maranatha.  \n'
                '  \n'
                'And that\'s all you have to do.  \n'
                '  \n'
                '---\n'
                '  \n'
                '*John Main OSB*',
            styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                textTheme:
                    const TextTheme(bodyMedium: TextStyle(fontSize: 20.0))))),
        Markdown(
            data: '# Closing Prayer\n'
                '  \n'
                '---\n'
                '  \n'
                'May this group be a true spiritual home '
                'for the seeker, a friend for the lonely, '
                'a guide for the confused.  \n'
                '  \n'
                'May those who pray here be strengthened '
                'by the Holy Spirit to serve all who come '
                'and receive them as Christ himself.  \n'
                '  \n'
                'In the silence of this group may all the suffering, '
                'violence and confusion of the world encounter '
                'the power that will console, renew, and uplift the '
                'human spirit.  \n'
                '  \n'
                'May this silence be a power to open the hearts of '
                'men and women to the vision of God, and so to '
                'each other, in love and peace, justice and human '
                'dignity.  \n'
                '  \n'
                'May all the beauty of the Divine Life fill the hearts of '
                'all who pray here with joyful hope. '
                '  \n'
                'May all who come here weighed down by the '
                'problems of humanity leave giving thanks for the '
                'wonder of human life.  \n'
                '  \n'
                'We make this prayer through Christ our Lord. '
                '  \n'
                'Amen\n'
                '  \n'
                '---\n'
                '  \n'
                '\n*Laurence Freeman OSB*',
            styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                textTheme:
                    const TextTheme(bodyMedium: TextStyle(fontSize: 20.0))))),
      ],
    ),
  ),
);
