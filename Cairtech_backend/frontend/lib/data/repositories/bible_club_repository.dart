import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/bible_club_model.dart';

class BibleClubRepository {
  final ApiService _apiService;

  BibleClubRepository(this._apiService);

  /// Get all Bible Clubs
  Future<List<BibleClubModel>> getAllBibleClubs() async {
    final response = await _apiService.get(ApiConstants.bibleClubs);
    final data = response.data as List<dynamic>;
    return data.map((json) => BibleClubModel.fromJson(json)).toList();
  }

  /// Get a Bible Club by ID
  Future<BibleClubModel> getBibleClubById(String id) async {
    final response = await _apiService.get(ApiConstants.bibleClubById(id));
    return BibleClubModel.fromJson(response.data);
  }

  /// Get a Bible Club by code
  Future<BibleClubModel> getBibleClubByCode(String code) async {
    final response = await _apiService.get(ApiConstants.bibleClubByCode(code));
    return BibleClubModel.fromJson(response.data);
  }

  /// Create a new Bible Club (via admin endpoint)
  Future<String> createBibleClub({
    required String name,
    required String code,
    String? localisation,
    String? ville,
    String? schoolName,
    String? schoolLevel,
    String? dateCreation,
    int? capacityMax,
    String status = 'ACTIVE',
  }) async {
    final response = await _apiService.post(
      ApiConstants.bibleClubs,
      data: {
        'name': name,
        'code': code,
        'localisation': localisation,
        'ville': ville,
        'schoolName': schoolName,
        'schoolLevel': schoolLevel,
        'dateCreation': dateCreation,
        'capacityMax': capacityMax,
        'status': status,
      },
    );
    return response.data as String;
  }

  /// Full update of a Bible Club
  Future<String> updateBibleClub(String id, Map<String, dynamic> data) async {
    final response = await _apiService.put(ApiConstants.bibleClubById(id), data: data);
    return response.data as String;
  }

  /// Partial update of a Bible Club
  Future<BibleClubModel> patchBibleClub(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(ApiConstants.bibleClubById(id), data: data);
    return BibleClubModel.fromJson(response.data);
  }

  /// Delete a Bible Club
  Future<void> deleteBibleClub(String id) async {
    await _apiService.delete(ApiConstants.bibleClubById(id));
  }
}
