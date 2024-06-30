import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HashTable',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'HashTable'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late double _deviceWidth;
  final int tableSize = 10;
  final List<List<String>> table = List.generate(10, (_) => []);
  final TextEditingController inputController = TextEditingController();
  String statusMessage = 'Status: Ready';
  bool isAnimating = false;
  String? animatingKey;
  int animatingIndex = 0;
  int animatingChainPosition = 0;
  double currentX = 0.0, currentY = 0.0;
  double targetX = 0.0, targetY = 0.0;
  Timer? animationTimer;
  int animationStep = 0;
  static const int animationSteps = 20;
  static const int animationDelay = 20;
  bool movingToIndex = true;

  int f(String key){
    int fvalue = 0;
    for (int i = 0; i < key.length; i++) {
      fvalue = (fvalue + key.codeUnitAt(i)) * 31;
    }
    return (fvalue % tableSize).abs();
  }
  void animation(String key, int index) {
    setState(() {
      animatingKey = key;
      animatingIndex = index;
      animatingChainPosition = table[index].length;
      animationStep = 0;
      currentX = 10.0;
      currentY = -20.0;
      targetX = 10.0 + (120.0);
      targetY = index * (20.0 + 10.0) + 10.0;
      movingToIndex = true;
    });

    if (animationTimer != null && animationTimer!.isActive) {
      animationTimer!.cancel();
    }

    animationTimer =
        Timer.periodic(Duration(milliseconds: animationDelay), (timer) {
          setState(() {
            if (animationStep < animationSteps) {
              currentX +=
                  (targetX - currentX) / (animationSteps - animationStep + 1);
              currentY +=
                  (targetY - currentY) / (animationSteps - animationStep + 1);
            } else {
              if (movingToIndex) {
                movingToIndex = false;
                animationStep = 0;
                targetX = 10.0 + (120.0) * (animatingChainPosition + 1);
              } else {
                currentX +=
                    (targetX - currentX) / (animationSteps - animationStep + 1);
                if (animationStep >= animationSteps) {
                  timer.cancel();
                  table[animatingIndex].add(animatingKey!);
                  animatingKey = null;
                  isAnimating = false;
                  statusMessage = '$key Is Added successfully ! ';
                }
              }
            }
            animationStep++;
          });
        });
  }

  void add(String key) {
    if (isAnimating) return;
    int index = f(key);
    if (!table[index].contains(key)) {
      isAnimating = true;
      animation(key, index);
      statusMessage = ' " $key " Added Successfully !';
    } else {
      setState(() {
        statusMessage = ' " $key " Is Already Exists !';
      });
    }

  }

  void remove(String key) {
    int index = f(key);
    if (table[index].contains(key)) {
      setState(() {
        table[index].remove(key);
        statusMessage = '" $key " Removed Successfully !';
      });
    } else {
      setState(() {
        statusMessage = '" $key " Key Not Found !';
      });
    }

  }

  int thesize() {
    int size = 0;
    for (var list in table) {
      size += list.length;
    }
    return size;
  }

  bool contains(String key) {
    int index = f(key);
    bool found = table[index].contains(key);
    setState(() {
      statusMessage = found ? " $key Is Found !" : "$key Is Not Found !";
    });
    return found;
  }


  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width:
                  _deviceWidth,
                  child:
                  CustomPaint(
                    painter: TablePainter(
                      table: table,
                      animatingKey: animatingKey,
                      currentX: currentX,
                      currentY: currentY,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: inputController,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black12),
                  border: OutlineInputBorder(),
                  labelText: 'Give An Input !! ',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(statusMessage),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black38, // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    maximumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    String key = inputController.text.trim();
                    if (key.isNotEmpty) {
                      add(key);
                      inputController.clear();
                    }
                  },
                  child: const SizedBox(
                    width: 200,
                    child: Text(
                      ' ADD (+) ',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black38, // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    maximumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    String key = inputController.text.trim();
                    if (key.isNotEmpty) {
                      remove(key);
                      inputController.clear();
                    }
                  },
                  child: const SizedBox(
                    width: 200,
                    child: Text(
                      'REMOVE (-)',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black38, // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    maximumSize: Size(200, 50),
                  ),
                  onPressed: () {
                    String key = inputController.text.trim();
                    if (key.isNotEmpty) {
                      contains(key);
                      inputController.clear();
                    }
                  },
                  child: const SizedBox(
                    width: 200,
                    child: Text(
                      'CONTAINS (?)',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.black38, // Set the background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    int size = thesize();
                    setState(() {
                      statusMessage = 'The Current Size Is: " $size " ';
                    });
                  },
                  child: const SizedBox(
                    width:155,
                    child: Text(
                      'SIZE (!)',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
class TablePainter extends CustomPainter {
  final List<List<String>> table;
  final String? animatingKey;
  final double? currentX, currentY;

  TablePainter(
      {required this.table, this.animatingKey, this.currentX, this.currentY});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.0;

    const double width = 130.0; // Ajuster la largeur des cellules
    const double height = 35.0; // Ajuster la hauteur des cellules
    const double padding = 5.0;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center, // Centrer le texte horizontalement
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < table.length; i++) {
      double x = padding + 80;
      double y = i * (height + padding) + padding + 20;

      // Dessiner la cellule d'index
      textPainter.text = TextSpan(
        text: '[           $i         ]',
        style: TextStyle(
            color: Colors.black, fontSize: 20),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x + padding, y + (height - textPainter.height) / 2));

      // Dessiner le rectangle de la cellule d'index
      canvas.drawRect(
        Rect.fromLTWH(x, y, width, height),
        paint,
      );

      for (int j = 0; j < table[i].length; j++) {
        double previousX = x;
        x += width + padding;
        canvas.drawRect(
          Rect.fromLTWH(x, y, width, height),
          paint,
        );
        // Dessiner la cellule de valeur
        textPainter.text = TextSpan(
          text: table[i][j],
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(x + padding + (width - textPainter.width) / 2,
                y + (height - textPainter.height) / 2));

        // Dessiner la ligne horizontale
        canvas.drawLine(
          Offset(previousX + width, y + height / 2),
          Offset(x, y + height / 2),
          paint,
        );
      }

      // Dessiner le symbole de fin-de-liste si la liste n'est pas vide
      if (table[i].isNotEmpty) {
        double previousX = x;
        x += width + padding;
        canvas.drawLine(
          Offset(previousX + width, y + height / 2),
          Offset(x, y + height / 2),
          paint,
        );

        // Dessiner la ligne verticale
        canvas.drawLine(
          Offset(x, y + padding),
          Offset(x, y + height - padding),
          paint,
        );

        // Dessiner les tirets horizontaux qui ne traversent pas la ligne verticale
        canvas.drawLine(
          Offset(x, y + padding),
          Offset(x + 10, y + padding + 4),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 4),
          Offset(x + 10, y + 8),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 8),
          Offset(x + 10, y + 12),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 12),
          Offset(x + 10, y + 16),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 16),
          Offset(x + 10, y + 20),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 20),
          Offset(x + 10, y + 24),
          paint,
        );
        canvas.drawLine(
          Offset(x, y + 24),
          Offset(x + 10, y + 28),
          paint,
        );
      }

      // Dessiner l'élément en cours d'animation si nécessaire
      if (animatingKey != null && i == table.length - 1) {
        paint.color = Colors.lightBlue.shade700;
        canvas.drawRect(
          Rect.fromLTWH(currentX!, currentY!, width, height),
          paint,
        );

        textPainter.text = TextSpan(
          text: animatingKey!,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(currentX! + padding,
                currentY! + (height - textPainter.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

