import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  Future<List<NotificationModel>> getAll() async {
    final response = await _apiService.get(ApiConstants.notifications);
    final data = response.data as List<dynamic>;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<List<NotificationModel>> getByRecipient(String recipient) async {
    final response = await _apiService.get(ApiConstants.notificationsByRecipient(recipient));
    final data = response.data as List<dynamic>;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<List<NotificationModel>> getUnread(String recipient) async {
    final response = await _apiService.get(ApiConstants.notificationsUnread(recipient));
    final data = response.data as List<dynamic>;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<NotificationModel> markAsRead(String id) async {
    final response = await _apiService.patch(ApiConstants.notificationMarkRead(id));
    return NotificationModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _apiService.delete(ApiConstants.notificationById(id));
  }
}
