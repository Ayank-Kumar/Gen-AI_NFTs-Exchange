import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:nft_frontend/Screens/AllMagazines.dart';
import 'package:nft_frontend/Screens/Contract/CreateProvider.dart';
import 'package:nft_frontend/Screens/Contract/NftProvider.dart';
import 'package:nft_frontend/Screens/CreateArticle.dart';
import 'package:nft_frontend/Screens/FinalSale.dart';
import 'package:nft_frontend/Screens/MyMagazines.dart';
import 'package:nft_frontend/Screens/PublishArticle.dart';
import 'package:nft_frontend/Screens/RenewSubscription.dart';
import 'package:provider/provider.dart';
import './Screens/Home.dart';
import './Screens/MagazineSubscribe.dart';
import 'Screens/Contract/ProfileProvider.dart';
import 'Screens/Profile.dart';
import 'Utilities/OpenAi.dart';

void main() {
  OpenAI.apiKey = OPEN_AI_API_KEY;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NftProvider()),
        ChangeNotifierProvider(create: (_) => CreateProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/All': (context) => const AllMagazines(),
        '/Subscribe': (context) => const Subscribe(),
        '/MyMagazines': (context) => const MyMagazines(),
        '/ReadArticle': (context) => const ReadArticle(),
        '/CreateArticle': (context) => const CreateArticle(),
        '/FinalSale': (context) => const FinalSale(),
        '/RenewSubscription': (context) => const RenewSubscription(),
        '/Profile': (context) => const Profile(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
