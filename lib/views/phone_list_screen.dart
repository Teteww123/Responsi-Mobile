import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';
import 'phone_detail_screen.dart';
import 'phone_form_screen.dart';
import 'favorite_page.dart';
import '../helpers/favorite_helper.dart';

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
    _loadFavorites();
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPhoneCard(Phone phone, bool isFavorite) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PhoneDetailScreen(phoneId: phone.id)),
        );
        _refresh();
      },
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[200],
                radius: 32,
                child: Icon(Icons.phone_android, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phone.brand,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "Rp${phone.price}",
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    tooltip: isFavorite ? "Hapus dari Favorite" : "Tambah ke Favorite",
                    onPressed: () => _toggleFavorite(phone.id),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 23, color: Colors.deepPurple),
                        tooltip: "Edit",
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
                        icon: const Icon(Icons.delete, size: 23, color: Colors.red),
                        tooltip: "Delete",
                        onPressed: () async {
                          await _presenter.deletePhone(phone.id);
                          _refresh();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[30],
      appBar: AppBar(
        title: const Text("Data HP", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
            tooltip: "Lihat Favorite",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
              _loadFavorites();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : _phoneList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mobile_off, size: 54, color: Colors.blueGrey[200]),
                          const SizedBox(height: 18),
                          const Text(
                            "Belum ada data handphone",
                            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _phoneList.length,
                      itemBuilder: (context, index) {
                        final phone = _phoneList[index];
                        final isFavorite = _favoriteIds.contains(phone.id);
                        return _buildPhoneCard(phone, isFavorite);
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PhoneFormScreen(isEdit: false)),
          );
          _refresh();
        },
      ),
    );
  }
}