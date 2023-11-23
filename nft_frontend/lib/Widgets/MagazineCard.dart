import 'package:flutter/material.dart';
import 'package:nft_frontend/Arguments/MagazinesGroup.dart';
import 'package:nft_frontend/Screens/Contract/ProfileProvider.dart';
import 'package:provider/provider.dart';
//import '../Arguments/Subscribe.dart';
import '../Arguments/Nft.dart';
import '../Utilities/Colors.dart';
import '../Utilities/urls.dart';

class MagazineCard extends StatefulWidget {
  // final ke bina widget. krke use nhi kr paa rhe the.
  final Source source;
  final List<dynamic> nft;
  const MagazineCard(this.source, this.nft, {super.key});

  @override
  State<MagazineCard> createState() => _MagazineCardState();
}

class _MagazineCardState extends State<MagazineCard> {
  @override
  Widget build(BuildContext context) {
    //print(widget.nft.length);
    final status = context.watch<ProfileProvider>();
    return Card(
      child: GestureDetector(
        // Ye null banane se unclickable ho jata hai
        onTap: () => (widget.source == Source.home)
            ? Navigator.pushNamed(context, '/Subscribe',
                arguments: NFTArgument(widget.nft))
            : (status.profileStatus)
                ? Navigator.pushNamed(context, '/MyMagazines',
                    arguments: MagazinesArguments(
                        widget.nft[0].toInt(), widget.source))
                : null,
        child: Card(
          elevation: 3.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  widget.nft[8],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: brandColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(9.0),
                    ),
                  ),
                  title: Center(
                      child:
                          Text(widget.nft[6], overflow: TextOverflow.ellipsis)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
