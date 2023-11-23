import 'package:flutter/material.dart';

//import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import 'package:turn_page_transition/turn_page_transition.dart';

//import '../Arguments/MagazinesGroup.dart';
import '../Arguments/Owner.dart';
import '../Arguments/Sale_Renew.dart';
import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';
import '../Utilities/urls.dart';
import 'Contract/NftProvider.dart';

class ReadArticle extends StatefulWidget {
  const ReadArticle({super.key});

  @override
  State<ReadArticle> createState() => _ReadArticleState();
}

class _ReadArticleState extends State<ReadArticle> {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as OwnerArguments;
    final nft = context.watch<NftProvider>();
    return Scaffold(
        backgroundColor: plainColor,
        appBar: AppBar(
          backgroundColor: plainColor,
          iconTheme: const IconThemeData(color: brandColor),
          elevation: 0.0,
          actions: [
            if (arguments.args.source == Source.myNfts)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                    backgroundColor: plainColor,
                    onPressed: () {
                      Navigator.pushNamed(context, '/FinalSale',
                          arguments:
                              Sale_RenewArguments(arguments.args.tokenId));
                    },
                    label: const Text(
                      "Place on Sale",
                      style: TextStyle(color: themeColor),
                    )),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20.0, bottom: 100, left: 20.0, right: 20.0),
            child: Column(children: [
              Text(
                arguments.nft[6],
                style: TextStyle(
                    color: brandColor, fontFamily: titleFont, fontSize: 24),
              ),
              FutureBuilder<int>(
                  future: nft.expiresAt(arguments.args.tokenId),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      // Ye bhi plugin se Number Format.
                      // Default 0 dega , sahi kiya hua tha hmne struct mai.
                      String days =
                          NumberFormat('#,##,000').format(snapshot.data!);

                      return (days.startsWith("0"))
                          ? Container()
                          : Text('Expires after: $days' " days");
                    }
                    return const SizedBox();
                  }),
              (arguments.args.source == Source.profileCollectibles)
                  ? const Divider(
                      color: Colors.green,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.tealAccent,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                    color: Colors.black, width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "${arguments.nft[4].length} Subscribers",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeColor),
                              ),
                            ),
                          )),
                    ),
              Text(
                arguments.nft[7],
                style: TextStyle(height: 1.6, fontFamily: bodyFont),
                textAlign: TextAlign.justify,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(arguments.nft[8]),
              ),
            ]),
          ),
        ),
        floatingActionButton: (arguments.args.source ==
                Source.profileCollectibles)
            ? null
            : Stack(
                children: [
                  Positioned(
                    bottom: 16.0,
                    left: 38.0,
                    child: FloatingActionButton.extended(
                      heroTag: "First",
                      onPressed: () {
                        nft.cancelSubscription(arguments.args.tokenId);
                        Navigator.pushNamed(context, "/All");
                      },
                      label: const Text('Cancel'),
                      icon: const Icon(Icons.cancel_presentation),
                      backgroundColor: Colors.red.shade800,
                    ),
                  ),
                  Positioned(
                    bottom: 16.0,
                    right: 6.0,
                    child: FloatingActionButton.extended(
                      heroTag: "Second",
                      onPressed: () {
                        Navigator.pushNamed(context, '/RenewSubscription',
                            arguments:
                                Sale_RenewArguments(arguments.args.tokenId));
                      },
                      label: const Text('Renew'),
                      icon: const Icon(Icons.repeat_one),
                      backgroundColor: Colors.greenAccent,
                    ),
                  ),
                ],
              )
        /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            /// Ye tha ek 3rd party plugin for turning page
            TurnPageRoute(
              overleafColor: Colors.grey.shade200,
              animationTransitionPoint: 0.6,
              // jyada effect nahi curvature mai
              transitionDuration: const Duration(milliseconds: 600),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              builder: (context) => const ReadArticle(),
              /// Ye next magazine pai bhejega ,
              /// appBar ka arrow hr baar pop krke pichhle pai until MyMagazines screen aa jaye
            ),
          );
        },
        label: const Text("Next"),
        icon: const Icon(Icons.navigate_next),
        backgroundColor: brandColor,
      ),*/

        );
  }
}
