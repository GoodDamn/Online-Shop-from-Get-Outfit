import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode, utf8;

void main() => runApp(new MaterialApp(
  title: 'Online Shop from Get Outfit',
  home:  new HomePage(),
  debugShowCheckedModeBanner: false,
));

class HomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>
{
  int _currentIndex = 0;
  final tabs =[
    Search(),
    Text("asd")
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online shop with Get Outfit"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search products',
              backgroundColor: Colors.blue
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Categories',
              backgroundColor: Colors.blue
          ),
        ],

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: tabs[_currentIndex],
    );
  }

}

class Search extends StatelessWidget {

  List data;
  String limit = "12";
  String name;
  String mainUrl = "http://server.getoutfit.ru/offers";


  void init() {
    this.getJsonData(mainUrl + "?limit=12");
  }

  Future<String> getJsonData(String url) async {
    var response = await http.get(
      Uri.encodeFull(url),
    );
    print(response);

    var convertDataToJson = utf8.decode(response.bodyBytes);
    convertDataToJson = "{\"results\": " + convertDataToJson + "}";
    print(convertDataToJson);
    var decodeJson = jsonDecode(convertDataToJson);
    data = decodeJson['results'];

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
    return  Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          onChanged: (content) {name = content;this.getJsonData(mainUrl + "?name=" + name + "&limit=" + limit);},
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search categories here',
          ),
        ),
        TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Set up limit"
          ),
          onChanged: (content) { limit = content;this.getJsonData(mainUrl + "?name=" + name + "&limit=" + limit);},
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
    );
  }

}

