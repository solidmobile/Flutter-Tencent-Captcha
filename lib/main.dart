import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert' as convert;
import 'widget/popup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tencent Captcha by JS and Webview",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Tencent Captcha by JS and Webview"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController _webViewController;
  String filePath = 'files/captcha.html';

  _showPopup(BuildContext context) {
    Navigator.push(
      context,
      PopupLayout(
        bgColor: Colors.white.withOpacity(0.5),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            title: Text("Tencent Captcha by JS and Webview"),
            leading: new Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  try {
                    Navigator.pop(context); //close the popup
                  } catch (e) {}
                },
              );
            }),
            brightness: Brightness.light,
          ),
          resizeToAvoidBottomPadding: false,
          body: new Builder(builder: (context) {
            return Scaffold(
              body: WebView(
                initialUrl: '',
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>[
                  _passingJavascriptChannel(context),
                ].toSet(),
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  _loadHtmlFromAssets();
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  JavascriptChannel _passingJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'FromJsToFlutter',
        onMessageReceived: (JavascriptMessage message) async {
          var jsonCaptcha = convert.jsonDecode(message.message);

          print(
              "ticket: ${jsonCaptcha["ticket"]} and  Rand: ${jsonCaptcha["randstr"]}");
          Navigator.pop(context);
        });
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html',
            encoding: convert.Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tencent Captcha by JS and Webview"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () => _showPopup(context),
              child: Text(
                "开始校验",
                style: TextStyle(color: Colors.lightBlue, fontSize: 23),
              ),
              shape: StadiumBorder(),
            )
          ],
        ),
      ),
    );
  }
}
