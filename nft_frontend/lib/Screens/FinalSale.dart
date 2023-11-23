import 'package:flutter/material.dart';
import 'package:nft_frontend/Utilities/func.dart';

import '../Arguments/Sale_Renew.dart';
import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';

class FinalSale extends StatefulWidget {
  const FinalSale({Key? key}) : super(key: key);

  @override
  State<FinalSale> createState() => _FinalSaleState();
}

class _FinalSaleState extends State<FinalSale> with Func {
  final TextEditingController priceController = TextEditingController();

  //final TextEditingController scheduleController = TextEditingController();

  final List<String> list = ["1 week", "1 month", "3 months"];
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Sale_RenewArguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandColor,
        title: Text(
          "Place on Sale",
          style: TextStyle(fontFamily: titleFont),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Todo - yaha bhi textfield ke upar wale text ko - textfield mai daal dena as hint in deco
            Text(
              "Set your Price",
              style: TextStyle(
                  fontFamily: bodyFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  suffixText: ' ETH',
                ),
              ),
            ),
            Text(
              "Set the Duration",
              style: TextStyle(
                  fontFamily: bodyFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
            // Ye to copypaste code.
            DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: darkColor),
              underline: Container(
                height: 2,
                color: brandColor,
              ),
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Container(
                margin: const EdgeInsets.all(40),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      Duration daysToSeconds = Duration(
                          days: (dropdownValue == "1 week")
                              ? 7
                              : (dropdownValue == "1 month")
                                  ? 28
                                  : 84);

                      /// Yaha se jo start kiya na parameter change karna
                      /// Fir Ctrl+Click karte karte , sb jagah theek kar diya parameter
                      /// Aur final marketplace.sol mai karna , wo to pata hi.
                      sellSubscription(
                          args.tokenId,
                          int.parse(priceController.text),
                          daysToSeconds.inDays,
                          context);
                      Navigator.pushNamed(context, "/All");
                    },
                    child: Text(
                      "Sell",
                      style: TextStyle(fontFamily: buttonFont, fontSize: 24),
                    )))
          ],
        ),
      ),
    );
  }
}
