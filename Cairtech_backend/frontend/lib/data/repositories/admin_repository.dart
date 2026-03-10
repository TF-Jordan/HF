import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  /// Create a new admin user
  Future<String> createAdmin({
    required String email,
    required String password,
    required String phoneNumber,
    String status = 'ACTIVE',
  }) async {
    final response = await _apiService.post(
      ApiConstants.createAdmin,
      data: {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'status': status,
      },
    );
    return response.data as String;
  }

  /// Create a new member (admin context)
  Future<String> createMember({
    required String email,
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? quarter,
    String? inscriptionDate,
    String? level,
    String? sector,
    required String idBbc,
  }) async {
    final response = await _apiService.post(
      ApiConstants.createMember,
      data: {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'address': address,
        'quarter': quarter,
        'inscriptionDate': inscriptionDate,
        'status': 'ACTIVE',
        'level': level,
        'sector': sector,
        'idBBC': idBbc,
      },
    );
    return response.data as String;
  }

  /// Create an InCharge (responsible/president)
  Future<String> createInCharge({
    required String email,
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? quarter,
    String? inscriptionDate,
    String? level,
    String? sector,
    required String idBbc,
    required String function,
    required String mandate,
    String? nominationDate,
    List<String>? competences,
  }) async {
    final response = await _apiService.post(
      ApiConstants.createInCharge,
      data: {
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'address': address,
        'quarter': quarter,
        'inscriptionDate': inscriptionDate,
        'status': 'ACTIVE',
        'level': level,
        'sector': sector,
        'idBBC': idBbc,
        'function': function,
        'mandate': mandate,
        'nominationDate': nominationDate,
        'competences': competences,
      },
    );
    return response.data as String;
  }

  /// Promote an existing user to Leader
  Future<String> createLeader(String email) async {
    final response = await _apiService.post(
      ApiConstants.createLeader,
      queryParameters: {'email': email},
    );
    return response.data as String;
  }
}
