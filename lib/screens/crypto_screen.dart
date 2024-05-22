import 'package:crypto_marcket_application/data/constant/constants.dart';
import 'package:crypto_marcket_application/data/model/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CoinListScreen extends StatefulWidget {
  CoinListScreen({Key? key, this.cryptoList}) : super(key: key);
  List<Crypto>? cryptoList;

  @override
  _CoinListScreenState createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptoList;
  bool isSearchingLoadingVisible = false;

  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              "Crypto Market",
              style: TextStyle(fontFamily: "morbaee", color: greyColor),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 170),
              child: Text(
                "by Sepehr",
                style: TextStyle(
                  fontFamily: "morbaee",
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _filterList(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        width: 4,
                        style: BorderStyle.solid,
                        color: greenColor,
                      ),
                    ),
                    filled: false,
                    // fillColor: greyColor,
                    hintText: "Insert CryptoCurrency",
                    hintStyle:
                        TextStyle(color: greyColor, fontFamily: "morbaee"),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: isSearchingLoadingVisible,
                child: Text(
                  "Updating...",
                  style: TextStyle(fontFamily: "morbaee", color: greenColor),
                )),
            Expanded(
              child: RefreshIndicator(
                color: blackColor,
                backgroundColor: greenColor,
                onRefresh: () async {
                  List<Crypto> freshData = await _getData();
                  setState(() {
                    cryptoList = freshData;
                  });
                },
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: cryptoList!.length,
                  itemBuilder: (context, index) {
                    return _getListTileItem(cryptoList![index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _getListTileItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(
            color: greenColor, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor),
      ),
      leading: SizedBox(
        width: 30,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(color: greyColor, fontSize: 15),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${crypto.priceUsd.toStringAsFixed(2)}",
                  style: TextStyle(color: greyColor, fontSize: 18),
                ),
                Text(
                  "% ${crypto.changePercent24hr.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: _getColorChangeText(crypto.changePercent24hr),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 30.0,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24hr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(
            Icons.trending_down,
            size: 24,
            color: redColor,
          )
        : Icon(
            Icons.trending_up,
            size: 24,
            color: greenColor,
          );
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptoList;
  }

  Future<void> _filterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];

    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchingLoadingVisible = true;
      });
      var result = await _getData();
      setState(() {
        cryptoList = result;
        isSearchingLoadingVisible = false;
      });
      return;
    }

    cryptoResultList = cryptoList!.where(
      (element) {
        return element.name
            .toLowerCase()
            .contains(enteredKeyword.toLowerCase());
      },
    ).toList();
    setState(() {
      cryptoList = cryptoResultList;
    });
  }
}
