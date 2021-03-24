import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';

import 'base_model.dart';

class SignUpViewModel extends BaseModel {
  AccountDAO dao = AccountDAO();

  SignUpViewModel() {}

  Future<AccountDTO> updateUser(Map<String, dynamic> user) async {
    try {
      setState(ViewStatus.Loading);
      final userDTO = AccountDTO(
        name: user["name"],
        email: user["email"],
        birthdate: user["birthdate"],
        phone: user["phone"],
        gender: user["gender"],
      );
      final updatedUser = await dao.updateUser(userDTO);
      // setToken here
      setState(ViewStatus.Completed);
      // await Future.delayed(Duration(seconds: 3));
      return updatedUser;
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await updateUser(user);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }
}
