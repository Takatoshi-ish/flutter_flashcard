import 'package:flutter/material.dart';
import './flashcard.dart';
import './objectbox.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CategoryPage(),
    );
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Store? store;
  Box<FlashCard>? flashCardBox;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  // Store と Box を用意します
  void initialize() async {
    store = await openStore();
    flashCardBox = store?.box<FlashCard>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳'),
      ),
      body: Container(
        padding: const EdgeInsets.all(25.0),
        alignment: Alignment.center,
        child: GestureDetector(
          child: const CategoryCard(categoryName: 'Flutter'),
          onTap: () {
            Navigator.of(context).push<FlashCard>(
              MaterialPageRoute(
                builder: (context) {
                  return FlashCardListPage(
                      flashCardBox: flashCardBox!, title: 'Flutter');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryName;
  const CategoryCard({
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 150,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0x29000000),
                offset: Offset(0, 3),
                blurRadius: 6,
                spreadRadius: 0),
          ],
        ),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              border: Border.all(color: const Color(0xff007aff), width: 0.5),
            ),
            child: Center(
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlashCardListPage extends StatefulWidget {
  Box<FlashCard> flashCardBox;
  final String title;
  FlashCardListPage({required this.flashCardBox, required this.title, Key? key})
      : super(key: key);

  @override
  State<FlashCardListPage> createState() => _FlashCardListPageState();
}

class _FlashCardListPageState extends State<FlashCardListPage> {
  Box<FlashCard>? flashCardBox;
  List<FlashCard> flashCards = [];

  /// Box から FlashCard 一覧を取得します
  void fetchFlashCard() {
    flashCards = flashCardBox?.getAll() ?? [];
    setState(() {});
  }

  @override
  void initState() {
    flashCardBox = widget.flashCardBox;
    fetchFlashCard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("単語帳"),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xff098a8c),
            border: Border.all(color: const Color(0xff098a8c), width: 1),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 10, bottom: 10),
            child: Text(
              '${widget.title} 用語集',
              style: const TextStyle(
                color: Color(0xffffffff),
                fontSize: 27,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0075,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ListView.builder(
              itemCount: flashCards.length,
              itemBuilder: (BuildContext context, int index) {
                final flashCard = flashCards[index];
                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black38),
                    ),
                  ),
                  child: ListTile(
                    trailing: const Icon(Icons.arrow_right_sharp),
                    title: Row(
                      children: [
                        Text(
                          flashCard.word,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        if (flashCard.star) ...{
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                        } else ...{
                          const Icon(Icons.star_outline),
                        }
                      ],
                    ),
                    onTap: () async {
                      final updateFlashCard =
                          await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) {
                            return FlashCardDetailPage(
                                flashCardBox: flashCardBox!, id: flashCard.id);
                          },
                        ),
                      );
                      if (updateFlashCard!) {
                        fetchFlashCard();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Text(
          '追加',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // ここで画面遷移とデータを新規追加しています
        onPressed: () async {
          final newFlashCard = await Navigator.of(context).push<FlashCard>(
            MaterialPageRoute(
              builder: (context) {
                return const AddFlashCardPage();
              },
            ),
          );
          if (newFlashCard != null) {
            flashCardBox?.put(newFlashCard);
            fetchFlashCard();
          }
        },
      ),
    );
  }
}

class AddFlashCardPage extends StatefulWidget {
  const AddFlashCardPage({super.key});

  @override
  State<AddFlashCardPage> createState() => _AddFlashCardPageState();
}

class _AddFlashCardPageState extends State<AddFlashCardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用語を追加'),
      ),
      body: TextFormField(
        onFieldSubmitted: (text) {
          final flashCard = FlashCard(word: text, star: false);
          Navigator.of(context).pop(flashCard);
        },
      ),
    );
  }
}

class FlashCardDetailPage extends StatefulWidget {
  Box<FlashCard> flashCardBox;
  final int id;
  FlashCardDetailPage({required this.flashCardBox, required this.id, Key? key})
      : super(key: key);

  @override
  State<FlashCardDetailPage> createState() => _FlashCardDetailPageState();
}

class _FlashCardDetailPageState extends State<FlashCardDetailPage> {
  Box<FlashCard>? flashCardBox;
  FlashCard? flashCard;

  void deleteFlashCard() {
    flashCardBox?.remove(widget.id);
  }

  @override
  void initState() {
    flashCardBox = widget.flashCardBox;
    flashCard = widget.flashCardBox.get(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: const Text("単語帳"),
        actions: [
          IconButton(
            onPressed: () {
              deleteFlashCard();
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Text(
            flashCard!.word,
            style: const TextStyle(
              fontFamily: 'SFProDisplay',
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              letterSpacing: 0.0075,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: (flashCard!.star)
              ? const Icon(
                  Icons.star,
                  color: Colors.yellow,
                )
              : const Icon(Icons.star_outline),
          // ここで画面遷移とデータを新規追加しています
          onPressed: () {
            flashCard!.star = (flashCard!.star) ? false : true;
            flashCardBox?.put(flashCard!);
            setState(() {});
          },
        ),
      ),
    );
  }
}
