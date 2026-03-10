import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/daily_verse_model.dart';

class DailyVerseRepository {
  final ApiService _apiService;

  DailyVerseRepository(this._apiService);

  Future<List<DailyVerseModel>> getAll() async {
    final response = await _apiService.get(ApiConstants.dailyVerse);
    final data = response.data as List<dynamic>;
    return data.map((json) => DailyVerseModel.fromJson(json)).toList();
  }

  Future<DailyVerseModel> getLatest() async {
    final response = await _apiService.get(ApiConstants.dailyVerseLatest);
    return DailyVerseModel.fromJson(response.data);
  }

  Future<DailyVerseModel> create(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.dailyVerse, data: data);
    return DailyVerseModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _apiService.delete(ApiConstants.dailyVerseById(id));
  }
}
