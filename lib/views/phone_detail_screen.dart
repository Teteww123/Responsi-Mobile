import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';

class PhoneDetailScreen extends StatefulWidget {
  final int phoneId;
  const PhoneDetailScreen({super.key, required this.phoneId});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  Phone? _phone;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() { _isLoading = true; });
    final presenter = PhonePresenter(_DummyView());
    try {
      final result = await presenter.getPhoneDetail(widget.phoneId);
      setState(() {
        _phone = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Detail")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : _phone == null
                  ? const Center(child: Text("No Data"))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(_phone!.imgUrl, width: 180, height: 180),
                          ),
                          const SizedBox(height: 16),
                          Text(_phone!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(_phone!.brand, style: TextStyle(fontSize: 18)),
                          Text("Rp${_phone!.price}", style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          Text("Specification:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_phone!.specification),
                        ],
                      ),
                    ),
    );
  }
}

class _DummyView implements PhoneView {
  @override
  void hideLoading() {}

  @override
  void showError(String message) {}

  @override
  void showLoading() {}

  @override
  void showPhoneList(List<Phone> phoneList) {}
}