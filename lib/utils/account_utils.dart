import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getOrCreateUserId() async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('userId');
  if (userId == null) {
    final uuid = Uuid();
    userId = uuid.v4();
    await prefs.setString('userId', userId);
  }
  return userId;
}
