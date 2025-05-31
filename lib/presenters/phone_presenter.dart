import '../models/phone.dart';
import '../network/network.dart';

abstract class PhoneView {
  void showLoading();
  void hideLoading();
  void showPhoneList(List<Phone> phoneList);
  void showError(String message);
}

class PhonePresenter {
  final PhoneView view;

  PhonePresenter(this.view);

  Future<void> loadPhoneData() async {
    view.showLoading();
    try {
      List<dynamic> data = await Network.getPhones();
      final phoneList = data.map((json) => Phone.fromJson(json)).toList();
      view.showPhoneList(phoneList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<Phone?> getPhoneDetail(int id) async {
    try {
      final data = await Network.getPhoneDetail(id);
      return Phone.fromJson(data);
    } catch (e) {
      view.showError(e.toString());
      return null;
    }
  }

  Future<void> createPhone(Phone phone) async {
    try {
      await Network.createPhone(phone.toJson());
    } catch (e) {
      view.showError(e.toString());
    }
  }

  Future<void> updatePhone(Phone phone) async {
    try {
      await Network.updatePhone(phone.id, phone.toJson());
    } catch (e) {
      view.showError(e.toString());
    }
  }

  Future<void> deletePhone(int id) async {
    try {
      await Network.deletePhone(id);
    } catch (e) {
      view.showError(e.toString());
    }
  }
}