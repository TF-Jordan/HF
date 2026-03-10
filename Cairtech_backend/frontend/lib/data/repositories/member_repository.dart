import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/member_model.dart';

class MemberRepository {
  final ApiService _apiService;

  MemberRepository(this._apiService);

  /// Get all members
  Future<List<MemberModel>> getAllMembers() async {
    final response = await _apiService.get(ApiConstants.members);
    final data = response.data as List<dynamic>;
    return data.map((json) => MemberModel.fromJson(json)).toList();
  }

  /// Get member by ID (returns JWT with member info)
  Future<String> getMemberById(String id) async {
    final response = await _apiService.get(ApiConstants.memberById(id));
    return response.data as String;
  }

  /// Get all members of a specific Bible Club
  Future<List<MemberModel>> getMembersByBbc(String bbcId) async {
    final response = await _apiService.get(ApiConstants.membersByBbc(bbcId));
    final data = response.data as List<dynamic>;
    return data.map((json) => MemberModel.fromJson(json)).toList();
  }

  /// Create a new member (from member context)
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
      ApiConstants.members,
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

  /// Change member status (ACTIVE / UNACTIVE)
  Future<MemberModel> changeMemberStatus(String id, String status) async {
    final response = await _apiService.patch(
      ApiConstants.changeMemberStatus(id, status),
    );
    return MemberModel.fromJson(response.data);
  }
}
