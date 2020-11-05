import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/enums/view_status.dart';


class BaseModel extends Model {
  ViewStatus _status = ViewStatus.Completed;

  ViewStatus get status => _status;

  void setState(ViewStatus newState) {
    _status = newState;

    notifyListeners();
  }
}
