import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode, utf8;

bool visibleProgress = false;

List dataProducts, dataCategory, details;
int detailIndex;
String limit = "12", name;
const String offersUrl = "http://server.getoutfit.ru/offers",
  categoriesUrl = "http://server.getoutfit.ru/categories";

hexColor(String hex)
{
  String newColor = '0xff' + hex;
  newColor = newColor.replaceAll('#', '');
  return int.parse(newColor);
}

Future<String> getProductDetails(String url) async {
  var response = await http.get(
    Uri.encodeFull(url),
  );
  print(response);

  visibleProgress = true;
  var convertDataToJson = utf8.decode(response.bodyBytes);
  convertDataToJson = "{\"results\": " + convertDataToJson + "}";
  print(convertDataToJson);
  var decodeJson = jsonDecode(convertDataToJson);
  details = decodeJson['results'];
  visibleProgress = false;

  return "Success";
}


Future<String> getJsonDataForCategories(String url) async {
  var response = await http.get(
    Uri.encodeFull(url),
  );
  print(response);

  visibleProgress = true;
  var convertDataToJson = utf8.decode(response.bodyBytes);
  convertDataToJson = "{\"results\": " + convertDataToJson + "}";
  print(convertDataToJson);
  var decodeJson = jsonDecode(convertDataToJson);
  dataCategory = decodeJson['results'];
  visibleProgress = false;

  return "Success";
}

Future<String> getJsonDataForProducts(String url) async {
  var response = await http.get(
    Uri.encodeFull(url),
  );
  print(response);

  visibleProgress = true;
  var convertDataToJson = utf8.decode(response.bodyBytes);
  convertDataToJson = "{\"results\": " + convertDataToJson + "}";
  print(convertDataToJson);
  var decodeJson = jsonDecode(convertDataToJson);
  dataProducts = decodeJson['results'];
  visibleProgress = false;

  return "Success";
}

/////////////////////////MAIN PART///////////////////////
void main() => runApp(new MaterialApp(
  title: 'Online Shop from Get Outfit',
  theme: new ThemeData(scaffoldBackgroundColor: Color(hexColor('#2D3447'))),
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
    Categories()
  ];

  @override
  void initState() {
    super.initState();
    getJsonDataForProducts(offersUrl + "?limit=12");
    getJsonDataForCategories(categoriesUrl + "?limit=12");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(hexColor('#2D3447')),
      appBar: AppBar(
        backgroundColor: Color(hexColor('#424D68')),
        title: Text("Online shop with Get Outfit"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(hexColor('#424D68')),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search products',
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Categories',
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

// Search screen
class Search extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          onChanged: (content) {name = content; getJsonDataForProducts(offersUrl + "?name=" + name + "&limit=" + limit);},
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search categories here',
            hintStyle: TextStyle(color: Colors.white)
          ),
        ),
        TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Set up limit",
              hintStyle: TextStyle(color: Colors.white)
          ),
          onChanged: (content) {limit = content; getJsonDataForProducts(offersUrl + "?name=" + name + "&limit=" + limit);},
        ),
        Visibility(
            maintainAnimation: true,
            maintainSize: true,
            maintainState: true,
            visible: visibleProgress,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color> (Colors.indigoAccent),
            )
        ),
        Expanded(
            child: ListView.builder(
                itemCount: dataProducts == null ? 0 : dataProducts.length,
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    child: Center(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ProductDetail()));
                                getProductDetails(offersUrl + "?categoryId=" + dataProducts[index]['categoryId'].toString());
                                detailIndex = index;
                              },
                              child: Card(
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(dataProducts[index]['name']),
                                      Text("ID Категории: " + dataProducts[index]['categoryId'].toString())
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(25.0),
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

// Categories screen
class Categories extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          onChanged: (content) {getJsonDataForCategories(categoriesUrl + "?name=" + content);},
          decoration: InputDecoration(
            hintText: 'Search categories here',
            hintStyle: TextStyle(color: Colors.white)
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: dataCategory == null ? 0 : dataCategory.length,
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    child: Center(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            GestureDetector(
                              child: Card(
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(dataCategory[index]['name']),
                                      Text("ID Категории: " + dataCategory[index]['categoryId'].toString())
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(15.0),
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

class ProductDetail extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(hexColor('#424D68')),
        title: Text("Product details"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(details[detailIndex]['name']),
            Text(details[detailIndex]['currencyId']),
            Text(details[detailIndex]['price'].toString())
          ],
        ),
      ),
    );
  }
}
