import 'package:flutter/material.dart';
import '../network/network.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';
import 'phone_form_screen.dart';
import '../helpers/favorite_helper.dart';

class PhoneDetailScreen extends StatefulWidget {
  final int phoneId;
  const PhoneDetailScreen({super.key, required this.phoneId});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> implements PhoneView {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  late PhonePresenter _presenter;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _presenter = PhonePresenter(this);
    _fetchDetail();
    _loadFavorite();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await Network.getPhoneDetail(widget.phoneId);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoriteHelper.isFavorite(widget.phoneId);
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoriteHelper.removeFavorite(widget.phoneId);
    } else {
      await FavoriteHelper.addFavorite(widget.phoneId);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  // PhoneView interface (for delete)
  @override
  void showLoading() {}
  @override
  void hideLoading() {}
  @override
  void showPhoneList(List<Phone> phoneList) {}
  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deletePhone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Phone"),
        content: const Text("Are you sure want to delete this phone?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirm == true) {
      await _presenter.deletePhone(widget.phoneId);
      if (mounted) Navigator.pop(context); // Kembali ke list (setelah hapus)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Detail"),
        actions: _data == null
            ? null
            : [
                IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? "Unfavorite" : "Favorite",
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhoneFormScreen(
                          isEdit: true,
                          phone: Phone(
                            id: _data!['id'],
                            name: _data!['name'],
                            brand: _data!['brand'],
                            price: _data!['price'],
                            specification: _data!['specification'] ?? "",
                          ),
                        ),
                      ),
                    ).then((_) => _fetchDetail());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deletePhone,
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _data == null
                  ? const Center(child: Text("No Data"))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _data!.entries.map((entry) {
                        if (entry.key == "img_url" &&
                            entry.value != null &&
                            entry.value.toString().isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Image.network(entry.value, height: 180),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${entry.key}: ",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  "${entry.value}",
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
    );
  }
}