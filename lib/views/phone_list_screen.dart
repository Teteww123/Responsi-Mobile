import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';
import 'phone_detail_screen.dart';
import 'phone_form_screen.dart';
import 'favorite_page.dart'; // Tambahkan ini
import '../helpers/favorite_helper.dart'; // Tambahkan ini

class PhoneListScreen extends StatefulWidget {
  const PhoneListScreen({super.key});

  @override
  State<PhoneListScreen> createState() => _PhoneListScreenState();
}

class _PhoneListScreenState extends State<PhoneListScreen> implements PhoneView {
  late PhonePresenter _presenter;
  bool _isLoading = false;
  List<Phone> _phoneList = [];
  String? _errorMessage;
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _presenter = PhonePresenter(this);
    _presenter.loadPhoneData();
    _loadFavorites();
  }

  void _refresh() {
    _presenter.loadPhoneData();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final list = await FavoriteHelper.getFavorites();
    setState(() {
      _favoriteIds = list.toSet();
    });
  }

  Future<void> _toggleFavorite(int id) async {
    if (_favoriteIds.contains(id)) {
      await FavoriteHelper.removeFavorite(id);
    } else {
      await FavoriteHelper.addFavorite(id);
    }
    _loadFavorites();
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showPhoneList(List<Phone> phoneList) {
    setState(() {
      _phoneList = phoneList;
    });
    _loadFavorites(); // refresh favorites jika data berubah
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data HP"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: "Lihat Favorite",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
              _loadFavorites(); // refresh icon favorite setelah kembali dari favorite page
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : ListView.builder(
                  itemCount: _phoneList.length,
                  itemBuilder: (context, index) {
                    final phone = _phoneList[index];
                    final isFavorite = _favoriteIds.contains(phone.id);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(phone.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${phone.brand} - Rp${phone.price}"),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhoneDetailScreen(phoneId: phone.id),
                            ),
                          );
                          _refresh();
                        },
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              tooltip: isFavorite ? "Hapus dari Favorite" : "Tambah ke Favorite",
                              onPressed: () => _toggleFavorite(phone.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PhoneFormScreen(isEdit: true, phone: phone),
                                  ),
                                );
                                _refresh();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _presenter.deletePhone(phone.id);
                                _refresh();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PhoneFormScreen(isEdit: false)),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}