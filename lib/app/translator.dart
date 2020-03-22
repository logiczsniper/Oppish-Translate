import 'package:oppish_translator/constants/strings.dart';

class Translator {
  static final String _op = "op";
  static final String _empty = "";
  static final String _space = " ";

  static String translate(String inputString, String inputLanguage) {
    if (inputString.isEmpty) return _empty;

    String output = _empty;
    String input = inputString.toLowerCase();
    switch (inputLanguage) {
      case Strings.english:

        /// Convert [input] from ENGLISH -> OPPISH
        for (String word in input.split(_space)) {
          for (String character in word.split(_empty)) {
            if (Strings.consonants.contains(character))
              output += character + _op;
            else
              output += character;
          }
          output += _space;
        }
        break;

      case Strings.oppish:

        /// Convert [input] from OPPISH -> ENGLISH
        for (String word in input.split(_space)) {
          for (int i = 0; i < word.length; i++) {
            String character = word[i];
            if (Strings.consonants.contains(character)) {
              output += character;
              i += _op.length;
            } else {
              output += character;
            }
          }
          output += _space;
        }
        break;

      default:
        throw AssertionError(Strings.invalidLanguage);
    }

    String preparedOutput = _capitalise(output.trim());

    return preparedOutput;
  }

  static String _capitalise(String input) {
    if (input.isEmpty)
      return input;
    else if (input.length == 1)
      return input.toUpperCase();
    else
      return input[0].toUpperCase() + input.substring(1);
  }
}
