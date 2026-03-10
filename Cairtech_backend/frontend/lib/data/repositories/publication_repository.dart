import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/publication_model.dart';

class PublicationRepository {
  final ApiService _apiService;

  PublicationRepository(this._apiService);

  Future<List<PublicationModel>> getAll() async {
    final response = await _apiService.get(ApiConstants.publications);
    final data = response.data as List<dynamic>;
    return data.map((json) => PublicationModel.fromJson(json)).toList();
  }

  Future<PublicationModel> getById(String id) async {
    final response = await _apiService.get(ApiConstants.publicationById(id));
    return PublicationModel.fromJson(response.data);
  }

  Future<PublicationModel> create(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.publications, data: data);
    return PublicationModel.fromJson(response.data);
  }

  Future<PublicationModel> update(String id, Map<String, dynamic> data) async {
    final response = await _apiService.patch(ApiConstants.publicationById(id), data: data);
    return PublicationModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _apiService.delete(ApiConstants.publicationById(id));
  }
}
