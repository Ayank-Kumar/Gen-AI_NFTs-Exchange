import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nft_frontend/Utilities/func.dart';
import 'package:provider/provider.dart';
import 'package:status_alert/status_alert.dart';
import 'package:web3dart/web3dart.dart';

import '../Arguments/Nft.dart';
//import '../Arguments/Subscribe.dart';

import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';
import '../Utilities/urls.dart';

import 'Contract/NftProvider.dart';
import 'Contract/ProfileProvider.dart';

class Subscribe extends StatefulWidget {
  const Subscribe({Key? key}) : super(key: key);

  @override
  State<Subscribe> createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> with Func {
  bool favorite = false;
  int days = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as NFTArgument;
    final status = context.watch<ProfileProvider>();
    final nft = context.watch<NftProvider>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, "/All");
        // Todo - see if returning true makes any difference
        return false; // Future<bool> chahiye tha
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    favorite = !favorite;
                  });
                  if (favorite == true) {
                    nft.likeSubscription(args.nft[0].toInt());
                  } else {
                    nft.unlikeSubscription(args.nft[0].toInt());
                  }
                },
                icon: Icon((favorite == true)
                    ? Icons.favorite
                    : Icons.favorite_outline)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.share))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    bottom: 10.0, right: 10.0, left: 10.0),
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Image.network(
                  args.nft[8],
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  args.nft[6],
                  style: TextStyle(
                      color: themeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: titleFont),
                ),
              ),
              FutureBuilder<int>(
                future: nft.expiresAt(args.nft[0].toInt()),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                    days = snapshot.data!;
                    String xdays = NumberFormat('#,##,000').format(days);
                    return Text(
                      'Expires after: $xdays' " days",
                      style: TextStyle(
                          fontFamily: bodyFont,
                          fontSize: 15,
                          color: dangerColor,
                          fontWeight: FontWeight.w600),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    text: TextSpan(
                        text:
                            "${args.nft[7].toString().substring(0, 200)}...... - ",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: bodyFont,
                            color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Subscribe to read the complete Article",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: bodyFont,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.yellowAccent,
                                color: Colors.black),
                          ),
                          const TextSpan(
                              text: "😊 ",
                              style: TextStyle(
                                  //backgroundColor: Colors.tealAccent,
                                  ))
                        ]),
                  )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      "Created by: ",
                      style: TextStyle(fontFamily: bodyFont),
                    ),
                    const Spacer(),
                    ActionChip(
                      label: Text(
                        (args.nft[1] == EthereumAddress.fromHex(dummyAddress))
                            ? "You"
                            : "${args.nft[1].toString().substring(0, 8)}...",
                        style: TextStyle(
                            color: plainColor,
                            fontSize: 16,
                            fontFamily: bodyFont,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        if (args.nft[1] !=
                            EthereumAddress.fromHex(dummyAddress)) {
                          nft.getUserProfile(args.nft[1]);
                          status.setProfile(false);
                          Navigator.pushNamed(context, "/Profile");
                        }
                      },
                      backgroundColor: brandColor,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: themeColor,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(
                "${args.nft[3]} Eth",
                style: TextStyle(
                    color: plainColor,
                    fontSize: 16,
                    fontFamily: bodyFont,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  if (days == 0) {
                    showDialog("Expired NFT");
                  } else if (args.nft[1] ==
                      EthereumAddress.fromHex(dummyAddress)) {
                    showDialog("Your own NFT");
                  } else {
                    buySubscription(args.nft[0].toInt(), args.nft[3], context);
                    Navigator.pushNamed(context, '/All');
                  }
                },
                icon: const Icon(
                  Icons.arrow_right_rounded,
                  color: plainColor,
                  size: 50,
                ),
                label: Text(
                  "Subscribe",
                  style: TextStyle(
                      fontFamily: buttonFont, fontSize: 20, color: plainColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showDialog(String str) {
    // ye iske liye ek chhota sa plugin download kiya tha
    // bing nai recommend
    StatusAlert.show(context,
        duration: const Duration(seconds: 2),
        title: 'Oopsies !',
        subtitle: str,
        titleOptions: StatusAlertTextConfiguration(
            style: const TextStyle(
                color: plainColor, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitleOptions: StatusAlertTextConfiguration(
            style: const TextStyle(color: plainColor)),
        configuration:
            const IconConfiguration(icon: Icons.cancel, color: brandColor),
        maxWidth: 300,
        backgroundColor: darkColor);
  }
}
