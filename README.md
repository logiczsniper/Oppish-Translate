# Oppish Translate
Small clone of Google translate but only translating between the Op-language (Oppish) and English. 

#### Features
-  Very similar look and feel to Google translate
-  fast
-  lightweight
-  Speech to text (English) capability
-  Text to speech (English + Oppish) capability
-  Adjust speech rate and pitch
-  Copy a translation to your clipboard
-  Save your favourite translations
-  Small trivia section

#### Dependencies
Uses `flutter_tts` and `speech_to_text` for basic audio capabilities. The Oppish text to speech method is built using the aforementioned packages.

`url_launcher` provides the `send feedback` functionality and I used `shared_preferences` to locally store the users favourite translations via simple `List<String>`. 

Lastly, I used ❤️ `provider` ❤️  for some state management. 