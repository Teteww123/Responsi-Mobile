import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../helpers/favorite_helper.dart';
import '../network/network.dart';
import 'phone_list_item.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Phone> _favoritePhones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final ids = await FavoriteHelper.getFavorites();
    List<Phone> favPhones = [];
    for (var id in ids) {
      try {
        final data = await Network.getPhoneDetail(id);
        favPhones.add(Phone.fromJson(data));
      } catch (_) {}
    }
    setState(() {
      _favoritePhones = favPhones;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Phones")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favoritePhones.isEmpty
              ? const Center(child: Text("Belum ada favorit"))
              : ListView.builder(
                  itemCount: _favoritePhones.length,
                  itemBuilder: (context, i) => PhoneListItem(phone: _favoritePhones[i]),
                ),
    );
  }
}