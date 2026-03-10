import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/bible_club_model.dart';

class BibleClubRepository {
  final ApiService _apiService;

  BibleClubRepository(this._apiService);

  /// Create a new Bible Club (admin only)
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
      ApiConstants.createBbc,
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

  // Note: The backend currently doesn't have a GET all BBCs endpoint exposed
  // in the controller, but BibleClubService has findAllBibleClubs().
  // When the endpoint is added, uncomment below:
  //
  // Future<List<BibleClubModel>> getAllBibleClubs() async {
  //   final response = await _apiService.get('/bibleclub');
  //   final data = response.data as List<dynamic>;
  //   return data.map((json) => BibleClubModel.fromJson(json)).toList();
  // }
}
