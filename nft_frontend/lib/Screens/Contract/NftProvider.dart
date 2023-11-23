import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../../Utilities/urls.dart';

class NftProvider extends ChangeNotifier {
  Web3Client? _web3client;
  ContractAbi? _abiCode;
  EthereumAddress? _contractAddress;
  DeployedContract? _deployedContract;

  /// blockchain contract ke sare function , import krke provider mai daal rahe hai
  /// taki statewide un functions ko use kr ske
  /// kind of wrappint the contract function in our UI function
  /// jo ki additional kaam kr rahe frontend mai + blockchain function bhi invoke kr rahe.
  ContractFunction? _addProfile;
  ContractFunction? _getProfile;
  ContractFunction? _profileCount;
  ContractFunction? _profiles;
  ContractFunction? _followProfile;

  ContractFunction? _getMyNfts;
  ContractFunction? _getCollectables;

  ContractFunction? _createNft;

  ContractFunction? _sellSubscription;
  ContractFunction? _getSubscriptions;
  ContractFunction? _buySubscription;
  ContractFunction? _renewSubscription;
  ContractFunction? _likeSubscription;
  ContractFunction? _unlikeSubsription;
  ContractFunction? _expiresAt;
  ContractFunction? _cancelSubscription;

  List<dynamic> _myProfile = [];
  List<dynamic> _userProfile = [];
  List<dynamic> _myNfts = [];
  List<dynamic> _collectables = [];
  List<dynamic> _nfts = [];

  double _balance = 0.0;
  int profileCount = 0;
  int _duration = 0;

  List<dynamic> get myProfile => _myProfile;
  List<dynamic> get userProfile => _userProfile;
  List<dynamic> get myNfts => _myNfts;
  List<dynamic> get collectables => _collectables;
  List<dynamic> get nfts => _nfts;
  double get balance => _balance;

  final EthPrivateKey _creds = EthPrivateKey.fromHex(dummyPrivateKey);
  // to initialise the web3socket clitent
  Future<void> init() async {
    _web3client = Web3Client(url, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    await getABI();
    await getDeployedContract();
  }

  //to read the ABI json file - our contract basically , wo sb extract hoke is json file mai
  // all methods and parameters.
  Future<void> getABI() async {
    final String abiFile = await rootBundle.loadString('assets/json/abi.json');
    final jsonABI = await json.decode(abiFile);
    _abiCode = ContractAbi.fromJson(
        json.encode(jsonABI['abi']), json.encode(jsonABI['contractName']));
    _contractAddress = EthereumAddress.fromHex(contractAddress);
  }
  // this acts as error checking - function invoked are first checked on this json file
  // then only after signalling - gooes to the smart contract deployed on blockchain.

  // the last of the 3 initialisation function - these all are necessary at starting
  Future<void> getDeployedContract() async {
    // Address and all the ways in which we will be accessing the methods.
    _deployedContract = DeployedContract(_abiCode!, _contractAddress!);
    // every response from smart contract comes in the form of a list,
    _addProfile = _deployedContract!.function('addProfile');
    _profiles = _deployedContract!.function('profiles');
    _followProfile = _deployedContract!.function('followProfile');

    // when moving to profile page
    _getProfile = _deployedContract!.function('profiles');
    _profileCount = _deployedContract!.function('getNumberOfUsers');
    _getMyNfts = _deployedContract!.function('getNfts');
    _getCollectables = _deployedContract!.function('getCollectables');

    //
    _sellSubscription = _deployedContract!.function('sellSubscription');
    _getSubscriptions = _deployedContract!.function('getSubscriptions');
    _buySubscription = _deployedContract!.function('buySubscription');
    _renewSubscription = _deployedContract!.function('renewSubscription');

    _likeSubscription = _deployedContract!.function('likeSubscription');
    _unlikeSubsription = _deployedContract!.function('unlikeSubscription');

    _cancelSubscription = _deployedContract!.function('cancelSubscription');
    _expiresAt = _deployedContract!.function('expiresAt');

    // creating nfts
    _createNft = _deployedContract!.function('createNFT');
  }

  Future<void> addProfile() async {
    await init(); // obvious
    /// This one (send Transaction) will consume (gas - infintesmal ether)
    await _web3client!.sendTransaction(
        _creds, // hamari private key
        Transaction.callContract(
            // getting our node - isse duplication of efforts nahi hota
            nonce: await _web3client!
                .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _addProfile!,
            parameters: []),
        chainId: 1337);
    _balance = await getBalance(dummyAddress);

    notifyListeners();
  }

  Future<void> followUser(String address) async {
    await init();
    //print(EthereumAddress.fromHex(address));
    try {
      await _web3client!.sendTransaction(
          _creds,
          Transaction.callContract(
              nonce: await _web3client!
                  .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
              from: EthereumAddress.fromHex(dummyAddress),
              contract: _deployedContract!,
              function: _followProfile!,
              parameters: [EthereumAddress.fromHex(address)]),
          chainId: 1337);
    } catch (e) {
      //print(e.toString());
    }
    notifyListeners();
  }

  Future<double> getBalance(String address) async {
    EtherAmount Inbalance =
        await _web3client!.getBalance(EthereumAddress.fromHex(dummyAddress));
    // kisi aur hi format mai return krta hai
    // hme double ki form mai chahiye tha, isliye.
    return Inbalance.getValueInUnit(EtherUnit.ether);
  }

  // getMyProfile works like - phle count fir utni baar chala ke sari profiles backend se.
  // Fir yaha pai apna
  Future<void> getMyProfile() async {
    await init(); // ye hamesha
    // server is called client, where our node is deployed .
    List profileList = await _web3client!.call(
        contract: _deployedContract!, function: _profileCount!, params: []);
    //print(profileList);
    BigInt totalProfiles = profileList[0]; // since sab kuchh list mai return
    profileCount = totalProfiles.toInt();
    List allProfiles = [];
    for (int i = 1; i < profileCount; i++) {
      List temp = await _web3client!.call(
          contract: _deployedContract!,
          function: _getProfile!, // Ban to jayega 2-D array.
          params: [BigInt.from(i)]);
      allProfiles.add(temp);
    }
    for (int i = 0; i < allProfiles.length; i++) {
      if (allProfiles[i][0] == EthereumAddress.fromHex(dummyAddress)) {
        _myProfile = allProfiles[i];
      }
    }
    notifyListeners();
  }

  Future<void> getMyNfts(String address) async {
    await init();
    // ye 3 toh required paramter hote hai
    List nftList = await _web3client!.call(
        sender: EthereumAddress.fromHex(address),
        contract: _deployedContract!,
        function: _getMyNfts!,
        params: []);
      // ismai backend mai ho sort krke  - fir bhi null wala aa jata hai - syd wo sb address se equal mai true

    _myNfts = nftList[0]; // hmesha 0 index hi dekha
    // To remove the null node - Wrna uske nfts sab mai show ho rahe the.
    _myNfts.removeAt(0);
    _myNfts.removeWhere(
        (item) => item[1] == EthereumAddress.fromHex(genesisAddress));

    notifyListeners();
  }

  Future<void> getCollectables(String address) async {
    await init();
    List collectableList = await _web3client!.call(
        sender: EthereumAddress.fromHex(address),
        contract: _deployedContract!,
        function: _getCollectables!,
        params: []);

    /// wo kya hai na SC sab list ki form mai return karta hai
    /// even though ek hi variable . Kind of taking a char through string input
    /// To hame [0] lagana parta  hai
    _collectables = collectableList[0]; // 0 hi aata hai bhai
    // Collectables mai - hr nft ki subscriber list mai jake - to thora extensive
    // To backend mai hi kar liya. Yaha pai seedha refined list.

    // Yeh to null address ke liye hai
    _collectables.removeWhere(
        (item) => item[1] == EthereumAddress.fromHex(genesisAddress));

    notifyListeners();
  }

  Future<void> createNft(
      String tokenUri, String title, String description) async {
    await init();
    await _web3client!.sendTransaction(
        // creds is basically private key.
        _creds,
        // Hamara Dummy Address hi hamar Using User hai
        Transaction.callContract(
            nonce: await _web3client!
                .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _createNft!,
            parameters: [tokenUri, title, description]),
        chainId: 1337);
    getMyNfts(dummyAddress); // this one has notify listeners - for UI change
  }

  Future<void> sellSubscription(int tokenId, int price, int duration) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
            value: EtherAmount.fromInt(EtherUnit.ether, price),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _sellSubscription!,
            parameters: [BigInt.from(tokenId), BigInt.from(duration)]),
        chainId: 1337);
  }

  Future<void> getSubscriptions() async {
    await init();
    List nftList = await _web3client!.call(
        contract: _deployedContract!, function: _getSubscriptions!, params: []);

    _nfts = nftList[0];
    nftList[0].removeAt(0);
    //_nfts = nftList[0];
    _nfts.removeWhere(
        (item) => item[1] == EthereumAddress.fromHex(genesisAddress));
    
    // Jo cancelled wale hai wo bhi hataye hai - ye kaam frontend mai - backend se khali list
    
    for (int i = 0; i < _nfts.length; i++) {
      int days = await expiresAt(_nfts[i][0].toInt());
      if (days == 0) {
        _nfts.remove(_nfts[i]);
      }
    }
    notifyListeners();
  }

  Future<void> buySubscription(int tokenId, BigInt price) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
            //the contract will get these ethers
            value: EtherAmount.fromBigInt(EtherUnit.wei, price),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _buySubscription!,
            parameters: [BigInt.from(tokenId)]),
        chainId: 1337); // - Ye sb blockchain/Server mai krne ke liye

    _balance = await getBalance(dummyAddress); // Ye bhi - pr not working - dobara kholne pai work ig 

    getCollectables(dummyAddress); // UI change
  }

  // Ye block/node. timestamp (NFT ke creation) + duration de raha tha days mai.
  Future<void> renewSubscription(int tokenId, int duration) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
            // initialization ke liye . nonce . Jaise phle se kuchh time ke liye recharge ho rakha ho
            // To uske aage utna add karega , initia value nonce mai do.
            nonce: await _web3client!.getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _renewSubscription!,
            parameters: [BigInt.from(tokenId), BigInt.from(duration)]),
        chainId: 1337);
    getMyNfts(dummyAddress); // pata nhi - syd need nahi hoti
  }

  // Simple
  Future<int> expiresAt(int tokenId) async {
    await init();
    List expiration = await _web3client!.call(
        contract: _deployedContract!,
        function: _expiresAt!,
        params: [BigInt.from(tokenId)]);
    _duration = expiration[0].toInt();
    return _duration;
  }

  Future<void> cancelSubscription(int tokenId) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
            nonce: await _web3client!
                .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
            from: EthereumAddress.fromHex(dummyAddress),
            contract: _deployedContract!,
            function: _cancelSubscription!,
            parameters: [BigInt.from(tokenId)]),
        chainId: 1337);
    getMyNfts(dummyAddress); // Apne hi kar raha hu na - To ismai change aur get Subscriptions pai
  }

  Future<void> likeSubscription(int tokenId) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
          nonce: await _web3client!
              .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
          from: EthereumAddress.fromHex(dummyAddress),
          contract: _deployedContract!,
          function: _likeSubscription!,
          parameters: [BigInt.from(tokenId)],
        ),
        chainId: 1337);
    getSubscriptions(); 
  }
  Future<void> unlikeSubscription(int tokenId) async {
    await init();
    await _web3client!.sendTransaction(
        _creds,
        Transaction.callContract(
          nonce: await _web3client!
              .getTransactionCount(EthereumAddress.fromHex(dummyAddress)),
          from: EthereumAddress.fromHex(dummyAddress),
          contract: _deployedContract!,
          function: _unlikeSubsription!,
          parameters: [BigInt.from(tokenId)],
        ),
        chainId: 1337);
    getSubscriptions(); // Data change in bloackhain - load it in frontend
  }

  Future<void> getUserProfile(EthereumAddress user) async {
    await init();
    List profileList = await _web3client!.call(
        contract: _deployedContract!, function: _profileCount!, params: []);
    BigInt totalProfiles = profileList[0];
    profileCount = totalProfiles.toInt();
    List allProfiles = [];
    for (int i = 1; i < profileCount; i++) {
      List temp = await _web3client!.call(
          contract: _deployedContract!,
          function: _profiles!,
          params: [BigInt.from(i)]);
      allProfiles.add(temp);
    }
    for (int i = 0; i < allProfiles.length; i++) {
      if (allProfiles[i][0] == user) {
        _userProfile = allProfiles[i]; // break here
      }
    }
    // Ye dono await khatam hone ke baad notify listeners called.
    getMyNfts(_userProfile[0].toString());
    getCollectables(_userProfile[0].toString());
    // Although time minute - to utna issue nahi.
    notifyListeners();
  }
}
