import 'package:flutter/material.dart';
import '../Arguments/Nft.dart';
//import '../Arguments/Subscribe.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<dynamic> searchTerms = [];
  CustomSearchDelegate(List<dynamic> s) {
    searchTerms = s;
  }

  /// These all methods come when we are extending SearchDelegate.
  @override
  List<Widget>? buildActions(BuildContext context) {
    // Actions as you know - they are a list occuring at the right end.
    return [
      IconButton(
        onPressed: () {
          // Jo type kiya [query] usko below string se replace
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Leading mtlb smjhte ho na - jo left starting mai
    return IconButton(
      onPressed: () {
        // Is class ka hi method
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> matchQuery = [];
    for (var mag in searchTerms) {
      if (mag[6].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(mag);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index][6];
        List<dynamic> nft = matchQuery[index];
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/Subscribe",
              arguments: NFTArgument(nft),
            );
          },
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> matchQuery = [];
    for (var mag in searchTerms) {
      if (mag[6].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(mag);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index][6];
        List<dynamic> nft = matchQuery[index];
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/Subscribe",
              arguments: NFTArgument(nft),
            );
          },
          title: Text(result),
        );
      },
    );
  }
}
