// nft provider (any screen can have it) and args

import 'package:flutter/material.dart';
import 'package:nft_frontend/Arguments/Owner.dart';
//import 'package:intl/intl.dart';
//import 'package:nft_frontend/Arguments/finalSale.dart';
import 'package:provider/provider.dart';
//import 'package:web3dart/web3dart.dart';

//import '../Arguments/Renew.dart';
import '../Arguments/MagazinesGroup.dart';
//import '../Arguments/finalSale.dart';
import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';
import '../Utilities/urls.dart';
import 'Contract/NftProvider.dart';

class MyMagazines extends StatefulWidget {
  const MyMagazines({Key? key}) : super(key: key);
  //static const routeName = "/Mymagazine";
  @override
  State<MyMagazines> createState() => _MyMagazinesState();
}

class _MyMagazinesState extends State<MyMagazines> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as MagazinesArguments;
    final nft = context.watch<NftProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              (args.source == Source.myNfts)
                  ? "Created Magazines"
                  : "Collected NFTs",
              style: TextStyle(
                  fontFamily: headlineFont, fontSize: 30, color: themeColor),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: const Divider(
                thickness: 1,
                color: brandColor,
              ),
            ),
            // duration (int) return krega na.
            Column(
              children: buildWidgets(context, nft, args),
            ),
          ],
        ),
      ),
      // whi ki khali user pai (apne nft magazines click krne pai)
    );
  }
}

List<Widget> buildWidgets(
    BuildContext context, NftProvider nfts, MagazinesArguments args) {
  //nfts.getCollectables(dummyAddress);

  List<Widget> x = [];

  List<dynamic> allNfts = (args.source == Source.profileCollectibles)
      ? nfts.collectables
      : nfts.myNfts;

  for (int i = 0; i < allNfts.length; i++) {
    x.add(
      Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8),
        child: Card(
          elevation: 5.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ArticleImage(allNfts[i][8]),
                ArticleTopic((args.source == Source.myNfts), allNfts[i], args),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return x;
}

class ArticleTopic extends StatelessWidget {
  final List<dynamic>? nft;
  final MagazinesArguments args;
  final bool mine;
  const ArticleTopic(this.mine, this.nft, this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const VerticalDivider(
            width: 2.0,
            thickness: 1,
            color: brandColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: Text(
                    nft![6],
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        color: themeColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/ReadArticle",
                          arguments: OwnerArguments(args, nft!));
                    },

                    /// with chatgpt the issue , every ui styling is independent from prev
                    /// so there is not a theme across the app.
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      // Button background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      (args.source == Source.profileCollectibles)
                          ? "Read Collectible"
                          : "Sell Or Renew",
                      style: const TextStyle(
                          fontSize: 11,
                          color: plainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                /*
                if (mine)
                  ActionChip(
                    backgroundColor: plainColor,
                    onPressed: () {
                      Navigator.pushNamed(context, "/FinalSale",
                          arguments: FinalSaleArguments(args.tokenId));
                    },
                    label: const Text(
                      "Place on Sale",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                */
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ArticleImage extends StatelessWidget {
  final String? url;
  const ArticleImage(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 18.0),
        child: Image.network(url!),
      ),
    );
  }
}
