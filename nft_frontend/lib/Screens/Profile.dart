import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:nft_frontend/Screens/Contract/NftProvider.dart';
import 'package:nft_frontend/Utilities/func.dart';
import 'package:provider/provider.dart';

import '../Utilities/urls.dart';
import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';
import '../Widgets/MagazineCard.dart';
import 'Contract/ProfileProvider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with Func {
  @override
  Widget build(BuildContext context) {
    final status = context.watch<ProfileProvider>();
    return (status.profileStatus)
        ? const MainBody()
        : Scaffold(
            appBar: AppBar(
              title: const Text("User Profile"),
            ),
            body: const MainBody(),
          );
  }
}

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  @override
  Widget build(BuildContext context) {
    final nft = context.watch<NftProvider>();
    final status = context.watch<ProfileProvider>();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FluttermojiCircleAvatar(
              // Todo - there is one customizable version too , you will have to add all the screens and options for it.
              backgroundColor: Colors.grey[200],
              radius: 70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              (status.profileStatus)
                  ? "${(nft.myProfile.isEmpty) ? dummyAddress : nft.myProfile[0].toString().substring(0, 8)}..."
                  : "${(nft.userProfile.isEmpty) ? dummyAddress : nft.userProfile[0].toString().substring(0, 8)}...",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: bodyFont,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Todo - these 3 column can be extracted into another widget .
              Column(
                children: [
                  Text(
                    nft.myNfts.length.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: themeColor,
                        fontFamily: bodyFont),
                  ),
                  const Text("My NFTs")
                ],
              ),
              Column(
                children: [
                  Text(
                    /// Ye jaruri tha kyunki waise wrna null wala (initial standar)
                    ///  pass ho jaa raha tha and error krwa de raha tha.
                    (nft.myProfile.isEmpty || nft.myProfile.length < 2)
                        ? "0"
                        : nft.myProfile[1].length().toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: themeColor,
                      fontFamily: bodyFont,
                    ),
                  ),
                  const Text("Followers")
                ],
              ),
              Column(
                children: [
                  Text(
                    (nft.myProfile.isEmpty || nft.myProfile.length < 3)
                        ? "0"
                        : nft.myProfile[2].length().toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: themeColor,
                        fontFamily: bodyFont),
                  ),
                  const Text("Following")
                ],
              ),
            ],
          ),
          // Todo - Very good video for Tab , yahi se dekh ke kiya hai maine - "https://youtu.be/POtoEH-5l40?si=LoulWOmKqNzAMc3N" ;
          (status.profileStatus)
              ? const SizedBox(
                  height: 40.0,
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        nft.followUser(nft.userProfile[0].toString());
                      },
                      child: const Text("Follow"))),
          DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  labelColor: brandColor,
                  unselectedLabelColor: themeColor,
                  labelStyle: TextStyle(
                      fontFamily: bodyFont, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(
                      text: "My NFTs",
                      icon: Icon(
                        Icons.pages,
                        color: brandColor,
                      ),
                    ),
                    Tab(
                      text: "Collectibles",
                      icon: Icon(
                        Icons.label,
                        color: brandColor,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: TabBarView(
                    children: [
                      nft.myNfts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: EmptyWidget(
                                image: null,
                                packageImage: PackageImage.Image_3,
                                title: 'No Magazines ',
                                subTitle:
                                    'You don\'t currently own any nft yet',
                                titleTextStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff9da9c7),
                                  fontWeight: FontWeight.w500,
                                ),
                                subtitleTextStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffabb8d6),
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: (1 / 1.5),
                                crossAxisCount: 2,
                              ),
                              itemCount: nft.myNfts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return MagazineCard(
                                    Source.myNfts, nft.myNfts[index]);
                              },
                            ),
                      (nft.collectables.isEmpty)
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: EmptyWidget(
                                image: null,
                                packageImage: PackageImage.Image_3,
                                title: 'No Magazines ',
                                subTitle:
                                    'You don\'t currently own any nft yet',
                                titleTextStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff9da9c7),
                                  fontWeight: FontWeight.w500,
                                ),
                                subtitleTextStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffabb8d6),
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: (1 / 1.5),
                                crossAxisCount: 2,
                              ),
                              itemCount: nft.collectables.length,
                              itemBuilder: (BuildContext context, int index) {
                                return MagazineCard(Source.profileCollectibles,
                                    nft.collectables[index]);
                              },
                            ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
