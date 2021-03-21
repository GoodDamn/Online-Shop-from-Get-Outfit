import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode, utf8;
import 'package:flutter/material.dart';

void main() => runApp(new MaterialApp(
  home: new HomePage(),
  debugShowCheckedModeBanner: false,
));

class HomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>
{

  final String url = "http://server.getoutfit.ru/categories";
  List data;

  @override
  void initState() {
    super.initState();
    this.getJsonData();
  }

  Future<String> getJsonData() async {
    var response = await http.get(
      Uri.encodeFull(url),
    );
    print(response);

    setState(() {
        data.clear();
        var convertDataToJson = utf8.decode(response.bodyBytes);
        convertDataToJson = "{\"results\": " + convertDataToJson + "}";
        print(convertDataToJson);
        var decodeJson = jsonDecode(convertDataToJson);
        data = decodeJson['results'];
    });

    return "Success";
  }

  void showSnackBar(int index, BuildContext context)
  {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text("ID Родителя: " + data[index]['parentId'].toString()),
      action: SnackBarAction(
        label: "HIDE",
        onPressed: scaffold.hideCurrentSnackBar
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online shop with Get Outfit"),
      ),
      body: Column(
        children: [
          TextField(
            textAlign: TextAlign.center,
            onChanged: (content) => {
              data.clear()
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search categories here',
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      child: Center(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => showSnackBar(index, context),
                                child: Card(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Text(data[index]['name']),
                                        Text("ID Категории: " + data[index]['id'].toString())
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(35.0),
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                    );
                  }
              )
          )
        ],
      ) 
    );
  }

}

