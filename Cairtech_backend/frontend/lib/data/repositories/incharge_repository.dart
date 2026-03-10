import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/incharge_model.dart';

class InchargeRepository {
  final ApiService _apiService;

  InchargeRepository(this._apiService);

  /// Get all InCharge persons
  Future<List<InchargeModel>> getAllInCharges() async {
    final response = await _apiService.get(ApiConstants.inCharges);
    final data = response.data as List<dynamic>;
    return data.map((json) => InchargeModel.fromJson(json)).toList();
  }

  /// Create a member from InCharge context
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
      ApiConstants.inChargeCreateMember,
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
}
