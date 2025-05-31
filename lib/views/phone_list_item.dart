import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../helpers/favorite_helper.dart';

class PhoneListItem extends StatefulWidget {
  final Phone phone;
  final VoidCallback? onTap;

  const PhoneListItem({Key? key, required this.phone, this.onTap}) : super(key: key);

  @override
  State<PhoneListItem> createState() => _PhoneListItemState();
}

class _PhoneListItemState extends State<PhoneListItem> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoriteHelper.isFavorite(widget.phone.id);
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoriteHelper.removeFavorite(widget.phone.id);
    } else {
      await FavoriteHelper.addFavorite(widget.phone.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      title: Text(widget.phone.name),
      subtitle: Text(widget.phone.brand),
      trailing: IconButton(
        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
        onPressed: _toggleFavorite,
      ),
    );
  }
}