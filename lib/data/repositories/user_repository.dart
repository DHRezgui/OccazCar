import '../datasources/remote/api_service.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String id);
}

class UserRepositoryImpl implements UserRepository {
  final ApiService _api;

  UserRepositoryImpl(this._api);

  @override
  Future<UserModel?> getUser(String id) async {
    final json = await _api.get('/users/$id');
    return UserModel.fromJson(json);
  }
}
