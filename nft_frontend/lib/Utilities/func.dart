import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_frontend/Utilities/httpService.dart';
import 'package:nft_frontend/Utilities/urls.dart';

import '../Screens/Contract/NftProvider.dart';

mixin Func {
  // html import kiya to usmai error dikha raha iska.
  Future<File> uploadMagazineCover() async {
    PickedFile? pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    File imageFile = File(pickedFile!.path);
    return imageFile;
  }

  createNft(File imageFile, String title, String description,
      BuildContext context) async {
    String tokenUri = await uploadToPinata(imageFile, title);
    NftProvider nftProvider = NftProvider();
    await nftProvider.createNft(tokenUri, title, description);
  }

// ipfs hosting service - to upload and store file using ipfs network
// scalable and reliable - good documentation.
  uploadToPinata(File imageFile, String title) async {
    /// you can pin image file or a json the contains the metadata of image
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path, filename: title)
    });

    HttpService httpService = HttpService();
    httpService.init(BaseOptions(
        baseUrl: pinataUrl,
        contentType: "multipart/form-data",
        headers: {
          "pinata_api_key": apiKey,
          "pinata_secret_api_key": apiSecret
        }));

    final response =
        await httpService.request(endpoint: pinEndpoint, formData: formData);
    print(response);
    print(pinataGateway + response['IpfsHash']);
    return pinataGateway + response['IpfsHash'];
  }

  sellSubscription(
      int tokenId, int price, int duration, BuildContext context) async {
    NftProvider nftProvider = NftProvider();
    await nftProvider.sellSubscription(tokenId, price, duration);
  }

  buySubscription(int tokenId, BigInt price, BuildContext context) async {
    NftProvider nftProvider = NftProvider();
    nftProvider.buySubscription(tokenId, price);
  }

  renewSubscription(int tokenId, int duration, BuildContext context) async {
    NftProvider nftProvider = NftProvider();
    nftProvider.renewSubscription(tokenId, duration);
  }
}
