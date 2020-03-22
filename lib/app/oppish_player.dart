import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:oppish_translator/constants/strings.dart';

class OppishPlayer {
  void speak(String rawInput, FlutterTts flutterTts) async {
    String output = "";
    String input = rawInput.toLowerCase();
    for (String word in input.split(" ")) {
      for (int i = 0; i < word.length; i++) {
        String character = word[i];
        if (Strings.consonants.contains(character)) {
          output += character + "op - ";
          i += 2;
        } else if (Strings.vowels.contains(character)) {
          output += character + " - ";
        } else if (Strings.punctuation.contains(character)) {
          sleep(Duration(milliseconds: 350));
        }
      }
    }
    flutterTts.speak(output);
  }
}
