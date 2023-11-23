import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:nft_frontend/Screens/Contract/NftProvider.dart';
import 'package:nft_frontend/Screens/CreateNFT.dart';
import 'package:nft_frontend/Screens/Profile.dart';
import 'package:nft_frontend/Utilities/urls.dart';
import 'package:nft_frontend/Widgets/CustomSearch.dart';
import 'package:provider/provider.dart';
import '../Utilities/Constant_Texts.dart';
import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';
import '../Widgets/MagazineCard.dart';
import 'Contract/ProfileProvider.dart';

class AllMagazines extends StatefulWidget {
  const AllMagazines({Key? key}) : super(key: key);

  @override
  State<AllMagazines> createState() => _AllMagazinesState();
}

class _AllMagazinesState extends State<AllMagazines> {
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    final nft = context.watch<NftProvider>();
    final status = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: plainColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontFamily: titleFont),
        ),
        backgroundColor: brandColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          (currIndex == 0)
              ? IconButton(
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(nft.nfts));
                  },
                  icon: const Icon(Icons.search),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ActionChip(
              onPressed: () {},
              backgroundColor: themeColor,
              label: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Icon(Icons.wallet),
                  ),
                  RichText(
                    // Ek hi paragraph ke different sections ko different
                    // styles dene mai useful
                    // Yaha pai TextSpan Recursive hota hai.
                    text: TextSpan(
                      text: nft.balance.toStringAsFixed(4),
                      children: const <TextSpan>[
                        TextSpan(
                          text: " ETH",
                          style: TextStyle(
                              color: brandColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: (currIndex == 0)
          ? (nft.nfts.isNotEmpty)
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: (1 / 1.5),
                    crossAxisCount: 2,
                  ),
                  itemCount: nft.nfts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MagazineCard(Source.home, nft.nfts[index]);
                  })
              : Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_3,
                    title: 'No Magazines ',
                    subTitle: 'No nft created yet',
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
          : (currIndex == 1)
              ? const CreateNFT()
              : const Profile(),
      bottomNavigationBar: BottomNavyBar(
        // 3rd party plugin dekha
        showElevation: true,
        selectedIndex: currIndex,
        itemCornerRadius: 24,
        curve: Curves.decelerate,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(bottomMenu[0]['icon']),
            title: Text(bottomMenu[0]['label']),
            activeColor: brandColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(bottomMenu[1]['icon']),
            title: Text(bottomMenu[1]['label']),
            activeColor: brandColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(bottomMenu[2]['icon']),
            title: Text(bottomMenu[2]['label']),
            activeColor: brandColor,
            textAlign: TextAlign.center,
          )
        ],
        onItemSelected: (index) async {
          if (index == 0) {
            nft.getSubscriptions();
          } else if (index == 2) {
            status.setProfile(true);
            nft.getMyProfile(); // isse following aur follower mil rahe 1st and 2nd index mai , 0-based indexing
            nft.getMyNfts(
                dummyAddress); // isi mai my nft wali value bhi initialise ho rahi hai.
            nft.getCollectables(dummyAddress);
          }
          setState(() {
            currIndex = index;
          });
        },
      ),
    );
  }
}
