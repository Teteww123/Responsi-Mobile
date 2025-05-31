import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';
import 'phone_detail_screen.dart';
import 'phone_form_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _presenter = PhonePresenter(this);
    _presenter.loadPhoneData();
  }

  void _refresh() => _presenter.loadPhoneData();

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
      appBar: AppBar(title: const Text("Phone Catalog")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : ListView.builder(
                  itemCount: _phoneList.length,
                  itemBuilder: (context, index) {
                    final phone = _phoneList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Image.network(phone.imgUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(phone.name),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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