import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';


const _hgPriceRequest = "https://api.hgbrasil.com/finance/stock_price?key=1fc7513f&symbol=";

class HGIdex extends StatefulWidget {
  const HGIdex({Key? key}) : super(key: key);

  @override
  _HGIdexState createState() => _HGIdexState();
}

class _HGIdexState extends State<HGIdex> {

  List<String> _symbols = [];
  double _price = 0;
  double _change = 0;
  String _symbol = "";

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _symbols = [...data];
      });
    });
  }

  _readData() async {
    final data = await rootBundle.loadString("assets/symbols.json");
    return json.decode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HGIdex'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DropdownSearch<String>(
            mode: Mode.MENU,
            showSelectedItems: true,
            items: _symbols,
            showSearchBox: true,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            onChanged: _getPrice,
          ),
          const Divider(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(_symbol, style: Theme.of(context).textTheme.headline5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("R\$$_price", style: Theme.of(context).textTheme.headline4),
                    Icon(_change == 0 ? Icons.ac_unit : _change < 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: _change == 0 ? Colors.grey : _change > 0 ? Colors.green : Colors.red,
                        size: 20),
                    Text("$_change",
                      style: TextStyle(
                          color: _change == 0 ? Colors.grey : _change > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          height: 0.2,
                      )
                    ),
                  ],
                )
              ]
            )
          )
        ],
      ),
    );
  }

  void _getPrice(String? value) async {
    if(value == null) {
      _price = 0;
      _symbol = "";
      _change = 0;
      return;
    }

    final split = value.split("-");
    final symbol = split[split.length -1].trim();
    http.get(Uri.parse("$_hgPriceRequest$symbol")).then((response) {
      final result = json.decode(response.body);
      setState(() {
        _price = result["results"][symbol]["price"];
        _change = result["results"][symbol]["change_percent"];
        _symbol = value;
      });
    });
  }
}