import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:oppish_translator/app/oppish_player.dart';
import 'package:oppish_translator/app/translation_view_model.dart';
import 'package:oppish_translator/constants/strings.dart';
import 'package:oppish_translator/favourites_view_model.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class TranslationPage extends StatefulWidget {
  final String title;
  TranslationPage({Key key, this.title}) : super(key: key);

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage>
    with TickerProviderStateMixin {
  TabController _inputController;
  TabController _outputController;
  TextEditingController _inputTextController;
  TextEditingController _outputTextController;
  FlutterTts flutterTts;
  OppishPlayer oppishPlayer;
  double slidedPitch;
  double slidedSpeed;
  SpeechToText flutterStt;
  Future<bool> available;

  String get _buildFavourite =>
      _inputTextController.text + " - " + _outputTextController.text;
  BorderSide get _borderSide => BorderSide(color: Colors.black26, width: 0.5);
  Icon get _placeholderIcon =>
      Icon(Icons.star_border, color: Colors.transparent);
  TextStyle get _textStyle => TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black54);

  IconButton get _volumeOutputIcon => IconButton(
      icon: Icon(Icons.volume_up),
      padding: EdgeInsets.zero,
      onPressed: _outputTextController.text.isEmpty
          ? null
          : () async {
              if (_outputController.index == 0) {
                /// Play ENGLISH audio.
                flutterTts.speak(_outputTextController.text);
              } else {
                /// Play OPPISH audio.
                oppishPlayer.speak(_outputTextController.text, flutterTts);
              }
            });

  IconButton get _volumeInputIcon => IconButton(
      icon: Icon(Icons.volume_up),
      padding: EdgeInsets.zero,
      onPressed: _inputTextController.text.isEmpty
          ? null
          : () async {
              if (_inputController.index == 0) {
                /// Play ENGLISH audio.
                flutterTts.speak(_inputTextController.text);
              } else {
                /// Play OPPISH audio.
                oppishPlayer.speak(_inputTextController.text, flutterTts);
              }
            });

  Widget _tabBar(TabController _controller) => Expanded(
        child: IgnorePointer(
            ignoring: _controller == _outputController,
            child: TabBar(
              isScrollable: true,
              controller: _controller,
              tabs: <Widget>[
                Tab(text: Strings.english),
                Tab(text: Strings.oppish),
              ],
            )),
      );

  Drawer _drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(Strings.quote,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                Align(
                  child: Text(
                    Strings.author,
                    style: TextStyle(color: Colors.white),
                  ),
                  alignment: Alignment.bottomRight,
                )
              ],
            )),
        Consumer<FavouritesViewModel>(
            builder: (context, favourites, _) => ExpansionTile(
                title: Text("Favourites"),
                children: List<Widget>.generate(favourites.favourites.length,
                    (index) => Text(favourites.favourites[index])))),
        ExpansionTile(
          title: Text("Settings"),
          children: <Widget>[
            Text("Pitch"),
            Slider(
              value: slidedPitch ?? 1.0,
              min: 0.5,
              max: 2.0,
              onChanged: (double pitch) {
                setState(() {
                  slidedPitch = pitch;
                });
              },
              onChangeEnd: (double value) {
                flutterTts.setPitch(value);
              },
            ),
            Text("Speed"),
            Slider(
              value: slidedSpeed ?? 0.45,
              min: 0.1,
              max: 0.9,
              onChanged: (double speed) {
                setState(() {
                  slidedSpeed = speed;
                });
              },
              onChangeEnd: (double value) {
                flutterTts.setSpeechRate(value);
              },
            )
          ],
        ),
        ExpansionTile(
          title: Text("Trivia"),
          children:
              List<Widget>.generate(3, (index) => Text(Strings.trivia[index])),
        ),
        Container(
          child: Text(
            "Mar '20",
            style: TextStyle(fontSize: 9.0, color: Colors.black45),
          ),
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(top: 80),
        )
      ],
    ));
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(widget.title),
    );
  }

  Widget _translator() {
    return ListView(children: <Widget>[
      Column(children: <Widget>[
        Card(
            margin: EdgeInsets.all(10.0),
            elevation: 2.0,
            child: Consumer2<TranslationViewModel, FavouritesViewModel>(
                builder: (context, model, favourites, _) =>
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Container(
                        decoration:
                            BoxDecoration(border: Border(bottom: _borderSide)),
                        child: Row(
                          children: <Widget>[
                            _tabBar(_inputController),
                            Padding(
                                child: IconButton(
                                    icon: Icon(Icons.swap_horiz),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _inputController.animateTo(
                                        _inputController.index == 0 ? 1 : 0)),
                                padding: EdgeInsets.symmetric(horizontal: 0.0)),
                            _tabBar(_outputController),
                          ],
                        ),
                      ),
                      Row(children: <Widget>[
                        Flexible(
                            child: Container(
                          padding: EdgeInsets.only(left: 0.0),
                          decoration:
                              BoxDecoration(border: Border(right: _borderSide)),
                          child: TextField(
                              controller: _inputTextController,
                              maxLines: 3,
                              minLines: 3,
                              style: _textStyle,
                              buildCounter: (BuildContext context,
                                  {currentLength, isFocused, maxLength}) {
                                return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            AbsorbPointer(
                                                absorbing:
                                                    _inputController.index == 1,
                                                child: GestureDetector(
                                                  child: IconButton(
                                                    icon: Icon(
                                                        Icons.keyboard_voice),
                                                    onPressed: _inputController
                                                                .index ==
                                                            1
                                                        ? null
                                                        : () {},
                                                  ),
                                                  onLongPressUp:
                                                      flutterStt.stop,
                                                  onLongPressStart: (_) {
                                                    _inputTextController
                                                        .clear();
                                                    available
                                                        .then((bool canListen) {
                                                      if (canListen)
                                                        flutterStt.listen(onResult:
                                                            (SpeechRecognitionResult
                                                                result) {
                                                          _inputTextController
                                                                  .text =
                                                              result
                                                                  .recognizedWords;
                                                        });
                                                    });
                                                  },
                                                )),
                                            _volumeInputIcon
                                          ]),
                                      Padding(
                                          child: Text("$currentLength/1000",
                                              style: TextStyle(
                                                  color: Colors.black54)),
                                          padding: EdgeInsets.only(right: 16.0))
                                    ]);
                              },
                              cursorWidth: 1.2,
                              decoration: InputDecoration(
                                  suffixIcon: _outputTextController.text.isEmpty
                                      ? _placeholderIcon
                                      : IconButton(
                                          icon: Icon(Icons.clear),
                                          color: Colors.black54,
                                          onPressed: () => WidgetsBinding
                                              .instance
                                              .addPostFrameCallback((_) =>
                                                  _inputTextController
                                                      .clear())))),
                        )),
                        Flexible(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: _outputTextController.text.isEmpty
                                        ? null
                                        : Colors.black.withAlpha(7)),
                                child: TextField(
                                    controller: _outputTextController,
                                    maxLines: 3,
                                    minLines: 3,
                                    readOnly: true,
                                    style: _textStyle,
                                    decoration: InputDecoration(
                                        hintText: Strings.translation,
                                        suffixIcon: _outputTextController
                                                .text.isEmpty
                                            ? _placeholderIcon
                                            : IconButton(
                                                icon: Icon(
                                                  favourites.isFavourite(
                                                          _buildFavourite)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.black54,
                                                ),
                                                padding: EdgeInsets.zero,
                                                onPressed:
                                                    favourites.isFavourite(
                                                            _buildFavourite)
                                                        ? () {
                                                            favourites
                                                                .removeFavourite(
                                                                    _buildFavourite);
                                                          }
                                                        : () {
                                                            favourites.addFavourite(
                                                                _buildFavourite);
                                                          })),
                                    buildCounter: (BuildContext context,
                                        {currentLength, isFocused, maxLength}) {
                                      return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            _volumeOutputIcon,
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  IconButton(
                                                      icon: Icon(
                                                          Icons.content_copy),
                                                      padding: EdgeInsets.zero,
                                                      onPressed:
                                                          model.output.isEmpty
                                                              ? null
                                                              : () {
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              model.output));
                                                                }),
                                                  IconButton(
                                                      icon: Icon(Icons.share),
                                                      padding: EdgeInsets.zero,
                                                      onPressed: null)
                                                ]),
                                          ]);
                                    })))
                      ])
                    ]))),
        Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                    onTap: () async {
                      const url = Strings.github;
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(Strings.feedback,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54)))))
      ])
    ]);
  }

  @override
  void initState() {
    super.initState();
    var _translationStatus =
        Provider.of<TranslationViewModel>(context, listen: false);

    _inputController = TabController(initialIndex: 0, length: 2, vsync: this);
    _outputController = TabController(initialIndex: 1, length: 2, vsync: this);
    _inputTextController = TextEditingController(text: "");
    _outputTextController = TextEditingController(text: "");

    _inputController.addListener(() {
      int _newValue = _inputController.index;
      _translationStatus.updateInputLanguage(_newValue);
      _inputTextController.clear();
      _outputController.animateTo(_inputController.previousIndex);
    });

    _inputTextController.addListener(() {
      String _newValue = _inputTextController.text;
      _translationStatus.translate(_newValue);
    });

    _translationStatus.addListener(() {
      String _newOutput = _translationStatus.output;
      _outputTextController.text = _newOutput;
    });

    flutterTts = FlutterTts();
    oppishPlayer = OppishPlayer();
    flutterStt = SpeechToText();
    available = flutterStt.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: _drawer(), appBar: _appBar(), body: _translator());
  }
}
