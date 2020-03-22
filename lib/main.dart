import 'package:flutter/material.dart';

import 'package:oppish_translator/app/translation_page.dart';
import 'package:oppish_translator/app/translation_view_model.dart';
import 'package:oppish_translator/constants/strings.dart';
import 'package:oppish_translator/favourites_view_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 12.0, top: 12.0),
          ),
          cursorColor: Colors.black45,
          iconTheme: IconThemeData(color: Colors.black54),
          tabBarTheme: TabBarTheme(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.5, color: Colors.blue)))),
      darkTheme: ThemeData.dark(),
      home: MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => TranslationViewModel()),
        ChangeNotifierProvider(create: (_) => FavouritesViewModel())
      ], child: TranslationPage(title: Strings.appTitle)),
    );
  }
}
