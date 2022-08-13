import 'package:objectbox/objectbox.dart';

@Entity() // @ ではじまるこのような記述を アノテーション といいます。
class FlashCard {
  FlashCard({
    required this.word,
    required this.star,
  });

  int id = 0; // id が必ず必要になります。初期値は0とします。

  String word = '';

  bool star = false;
}
