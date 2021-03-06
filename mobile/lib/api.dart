import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

class Food_icon {
  //homepage card parameters
  String name;
  String imagePath;
  String rest;
  double cost;
  List<String> ingredients;
  //homepage card paramters, integrate later.
  double profit;
  double sust;
  double investIndex; //this is an avg of profit and sust

  //detail ingredient card page
  bool dishProfitColor;
  List<double> dishProfitData;
  bool dishSustColor;
  List<double> dishSustData;
  bool dishBuysColor;
  List<int> dishBuysData;

  //detailpage for ingredients, might not need to include
  List<Ingredient> ingredientList;

  Food_icon(this.name, this.imagePath, this.rest, this.profit, this.sust,
      this.investIndex); //new homepage constructor

  Food_icon.fromDetail(
      this.dishProfitColor,
      this.dishProfitData,
      this.dishSustColor,
      this.dishSustData,
      this.dishBuysColor,
      this.dishBuysData);
}

Future<List<Food_icon>> getDishes(String id) async {
  var url = "http://35.235.92.165/biz/menu/${id}";
  final response = await http.get(url);
  List<Food_icon> arr = []; 

  String name;
  String imagePath;
  String restName = id;
  double profit;
  double sust;
  double invest;

  if (response.statusCode == 200) {
    Map<String, dynamic> items = convert.jsonDecode(response.body);
    items.forEach((key, item) {
      name = key;
      imagePath = item["link"]; //May be renamed in api
      sust = item["sust"];
      profit = item["profit"];
      invest = (profit + sust) / 2;
      arr.add(Food_icon(name, imagePath, restName, profit, sust, invest));
    });

  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }

  //var foodIcon = Food_icon(name, imagePath, restName, profit, sust, invest);
  return arr;
}

Future<Food_icon> getDishDetail(String item, String id) async {
  var url = "http://35.235.92.165/biz/item/${item}/${id}";
  final response = await http.get(url);

  bool dishProfitColor;
  List<double> dishProfitData;
  bool dishSustColor;
  List<double> dishSustData;
  bool dishBuysColor;
  List<int> dishBuysData;

  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    var data = jsonResponse[item];

    List<dynamic> list1 = data["profit"];
    dishProfitData = list1.cast<double>().toList();

    List<dynamic> list2 = data["sust"];
    dishSustData = list2.cast<double>().toList();

    List<dynamic> list3 = data["buys"];
    dishBuysData = list3.cast<int>().toList();

    print("Hello");

    print(dishProfitData);
    var profitPrediction = dishProfitData[dishProfitData.length - 1] -
        dishProfitData[dishProfitData.length - 2];
    if (profitPrediction > 0) {
      dishProfitColor = true;
    } else {
      dishProfitColor = false;
    }

    var dishSustPrediction = dishSustData[dishSustData.length - 1] -
        dishSustData[dishSustData.length - 2];
    if (dishSustPrediction > 0) {
      dishSustColor = true;
    } else {
      dishSustColor = false;
    }

    var dishBuysPrediction = dishBuysData[dishBuysData.length - 1] -
        dishBuysData[dishBuysData.length - 2];
    if (profitPrediction > 0) {
      dishBuysColor = true;
    } else {
      dishBuysColor = false;
    }

    return Food_icon.fromDetail(dishProfitColor, dishProfitData, dishSustColor,
        dishSustData, dishBuysColor, dishBuysData);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<List<Ingredient>> getIngredients(
    String foodItem, String type, String id) async {
  var url = "http://35.235.92.165/biz/ingredients/${foodItem}/${type}/${id}";
  final response = await http.get(url);
  List<Ingredient> ingredientList = [];

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
    jsonResponse.forEach((key, item) {
      List<double> data;
      bool color;
      String ingredientName = key;
      List<dynamic> list1 = item;
      data = list1.cast<double>().toList();

      var ingredientPrediction = data[data.length - 1] - data[data.length - 2];
      if (ingredientPrediction > 0) {
        color = true;
      } else {
        color = false;
      }
      ingredientList.add(Ingredient(ingredientName, color, data));
    });
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }

  return ingredientList;
}

postIngredients(String id, String dishName, List<String> ingredients) async{
    var url = "http://35.235.92.165/biz/new/${id}";
    var body = convert.jsonEncode({'name':dishName, 'ingredients':ingredients});

    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };

    http.post(url, body: body, headers: headers).then((response){
      print(response.statusCode);
      print(response.body);
    });
}

class Ingredient {
  String ingredientName;
  bool color;
  List<double> data;

  Ingredient(this.ingredientName, this.color, this.data);
}
