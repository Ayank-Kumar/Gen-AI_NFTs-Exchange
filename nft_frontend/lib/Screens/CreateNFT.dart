import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:http/http.dart' as http;
//import 'package:nft_frontend/Arguments/Create.dart';
import 'package:nft_frontend/Utilities/OpenAi.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
//import 'package:nft_frontend/Screens/Contract/CreateProvider.dart';
import 'package:nft_frontend/Utilities/func.dart';
//import 'package:provider/provider.dart';

//import '../Utilities/Constant_Texts.dart';
//import '../Utilities/Colors.dart';
import '../Utilities/Google_Fonts.dart';

class CreateNFT extends StatefulWidget {
  const CreateNFT({Key? key}) : super(key: key);

  @override
  State<CreateNFT> createState() => _CreateNFTState();
}

class _CreateNFTState extends State<CreateNFT> with Func {
  // Needed for each textFields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? imageFile;
  String? generation;
  int state = 0;
  final OpenAi = OpenAiSdk();
/*
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
*/
  Future<File> _fileFromImageUrl(String prompt) async {
    final Url = await OpenAi.makeImage(titleController.text);
    final response = await http.get(Uri.parse(Url!));

    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}' 'imagetest.png');

    file.writeAsBytesSync(response.bodyBytes);

    return file;
  }

  // ToDo :- try to integrate the label which is dissacociated from TextField into the TextField itself.
  @override
  Widget build(BuildContext context) {
    // seedhe likh diya karo , imports khud bata deta hai
    //final exec = context.watch<CreateProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (state >= 2)
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: DottedBorder(
                              dashPattern: const [6, 3],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              padding: const EdgeInsets.all(6),
                              child: ClipRRect(
                                  // obv match krna chahiye exact
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: Image.file(
                                    imageFile!,
                                  )),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(titleController.text),
                          ),
                        )
                      ],
                    )
                  : (state != 0)
                      ? Container()
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              "Enter prompt to Generate your Image",
                              style: TextStyle(
                                  fontFamily: bodyFont,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextField(
                            // fields bahut hai bahut kuchh try krne ke liye
                            controller: titleController,
                            maxLines: 1,
                          ),
                        ]),
              (state == 3)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedTextKit(
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(generation!,
                                speed: const Duration(milliseconds: 20),
                                textStyle: TextStyle(
                                    fontFamily: bodyFont, fontSize: 16),
                                curve: Curves.linear)
                          ]),
                    )
                  : (state != 0)
                      ? const Center(
                          child: RefreshProgressIndicator(),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text("Enter prompt for Article",
                                  style: TextStyle(
                                      fontFamily: bodyFont,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            TextField(
                              controller: descriptionController,
                              maxLines: null,
                              // ye taaki extend krke next line mai jaaye
                              // wrna usi line mai slider bn ke aage barta jaa raha tha
                            ),
                          ],
                        ),
              Container(
                margin: const EdgeInsets.all(40),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state == 3)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            imageFile = null;
                            generation = null;
                            setState(() {
                              state = 0;
                            });
                            //exec.clear();
                          },
                          child: Text(
                            "Retry   Prompt",
                            style: TextStyle(
                                color: Colors.red.shade800,
                                fontFamily: buttonFont,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (state == 3) {
                            createNft(imageFile!, titleController.text,
                                generation!, context);

                            titleController.clear();
                            descriptionController.clear();

                            imageFile = null;
                            generation = null;

                            //exec.clear();

                            Navigator.pushNamed(context, '/All');
                          } else {
                            //print(preview);
                            setState(() {
                              state = 1;
                            });

                            imageFile =
                                await _fileFromImageUrl(titleController.text);
                            setState(() {
                              state = 2;
                            });
                            //exec.setImageFile(imageFile!);

                            //sleep(const Duration(seconds: 60));
                            //print(preview);

                            generation = await OpenAi.getCompleteDescription(
                                descriptionController.text);
                            //exec.setDescription(generation!);
                            setState(() {
                              state = 3;
                            });
                          }
                        },
                        child: Text(
                          (state == 0)
                              ? "Preview   NFT"
                              : (state == 1)
                                  ? "Generating Image.."
                                  : (state == 2)
                                      ? "Generating your Article..."
                                      : "Publish   NFT",
                          style: TextStyle(
                              color: Colors.green,
                              fontFamily: buttonFont,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
Container(
                        margin: const EdgeInsets.all(40),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: ElevatedButton(
                          // Set State mai await nahi , isliye provider , jo ki rerender krde
                          onPressed: () {},
                          child: Text(
                            "Generate photo",
                            style:
                                TextStyle(fontFamily: buttonFont, fontSize: 24),
                          ),
                        ),
                      ),
*/