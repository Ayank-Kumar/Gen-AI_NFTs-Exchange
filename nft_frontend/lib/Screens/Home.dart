import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:nft_frontend/Screens/Contract/NftProvider.dart';
import 'package:provider/provider.dart';
import '../Utilities/Google_Fonts.dart';
import '../Utilities/Constant_Texts.dart';
import '../Utilities/Colors.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // listen wali hi baat hai.
    final nft = context.watch<NftProvider>();
    // ye bracket() - nhi to instance nahi - hence method access nahi kar pa rha tha
    return Scaffold(
      // Jb aapko appBar hatana ho, uske liye Safe Area.
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularText(
                  // Widget with Circular center and Circular Text.
                  children: [
                    TextItem(
                      text: Text(
                        "Creator".toUpperCase(),
                        style: TextStyle(
                            color: darkColor,
                            fontSize: 25,
                            fontFamily: headlineFont,
                            fontWeight: FontWeight.bold),
                      ),
                      space: 15,
                      // Space between characters
                      startAngle: -90,

                      startAngleAlignment: StartAngleAlignment.center,
                      // means text's center will occur at start angle

                      direction: CircularTextDirection.clockwise,
                    ),
                    TextItem(
                      text: Text("NFT Subscriptions".toUpperCase(),
                          style: TextStyle(
                              color: themeColor,
                              fontSize: 30,
                              fontFamily: headlineFont)),
                      space: 10,
                      startAngle: 90,
                      startAngleAlignment: StartAngleAlignment.center,
                      direction: CircularTextDirection.anticlockwise,
                    )
                  ],
                  radius: 60,
                  position: CircularTextPosition.outside,
                  backgroundPaint: Paint()..color = brandColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  tagLine,
                  style: TextStyle(
                      fontFamily: taglineFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: brandColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  description,
                  softWrap: true,
                  style: TextStyle(
                      fontFamily: bodyFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            nft.addProfile();
            nft.getSubscriptions();
            Navigator.pushNamed(context, "/All");
          },
          child: Text(
            landingAction,
            style: TextStyle(fontFamily: buttonFont, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
