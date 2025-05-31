import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../presenters/phone_presenter.dart';

class PhoneFormScreen extends StatefulWidget {
  final bool isEdit;
  final Phone? phone;

  const PhoneFormScreen({super.key, required this.isEdit, this.phone});

  @override
  State<PhoneFormScreen> createState() => _PhoneFormScreenState();
}

class _PhoneFormScreenState extends State<PhoneFormScreen> implements PhoneView {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _specCtrl;
  bool _isLoading = false;
  String? _error;

  late PhonePresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = PhonePresenter(this);
    _nameCtrl = TextEditingController(text: widget.phone?.name ?? "");
    _brandCtrl = TextEditingController(text: widget.phone?.brand ?? "");
    _priceCtrl = TextEditingController(text: widget.phone != null ? widget.phone!.price.toString() : "");
    _specCtrl = TextEditingController(text: widget.phone?.specification ?? "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = Phone(
      id: widget.phone?.id ?? 0,
      name: _nameCtrl.text,
      brand: _brandCtrl.text,
      price: int.tryParse(_priceCtrl.text) ?? 0,
      specification: _specCtrl.text,
    );
    setState(() => _isLoading = true);
    if (widget.isEdit) {
      await _presenter.updatePhone(phone);
    } else {
      await _presenter.createPhone(phone);
    }
    setState(() => _isLoading = false);
    if (_error == null && mounted) Navigator.pop(context); // Kembali ke list/detail
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void showPhoneList(List<Phone> phoneList) {}

  @override
  void showError(String message) {
    setState(() => _error = message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? "Edit Phone" : "Create Phone")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (v) => v!.isEmpty ? "Name required" : null,
                    ),
                    TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(labelText: "Brand"),
                      validator: (v) => v!.isEmpty ? "Brand required" : null,
                    ),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Price required" : null,
                    ),
                    TextFormField(
                      controller: _specCtrl,
                      decoration: const InputDecoration(labelText: "Specification"),
                      validator: (v) => v!.isEmpty ? "Specification required" : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(widget.isEdit ? "Update" : "Simpan"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}