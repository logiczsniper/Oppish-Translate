import 'package:flutter/foundation.dart';
import 'package:oppish_translator/app/translator.dart';
import 'package:oppish_translator/constants/strings.dart';

class TranslationViewModel extends ChangeNotifier {
  String _output;
  String _inputLanguage;

  String get output => _output ?? Strings.translation;
  String get inputLanguage => _inputLanguage ?? Strings.english;

  void updateInputLanguage(int index) {
    _inputLanguage = [Strings.english, Strings.oppish].elementAt(index);
  }

  void translate(String inputString) {
    String translation = Translator.translate(inputString, inputLanguage);
    _output = translation;
    notifyListeners();
  }
}
