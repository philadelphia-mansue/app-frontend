import '../models/candidate_model.dart';

abstract class CandidateMockDataSource {
  Future<List<CandidateModel>> getCandidates();
}

class CandidateMockDataSourceImpl implements CandidateMockDataSource {
  @override
  Future<List<CandidateModel>> getCandidates() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Parse mock data matching API format
    return _mockCandidatesJson.map((json) => CandidateModel.fromJson(json)).toList();
  }

  /// Mock data matching the expected API response format
  static final List<Map<String, dynamic>> _mockCandidatesJson = [
    {
      'id': '1',
      'name': 'Iulian',
      'surname': 'Balcan',
      'full_name': 'Iulian Balcan',
      'photo': 'https://i.pravatar.cc/300?u=iulian_balcan',
    },
    {
      'id': '2',
      'name': 'Lucian',
      'surname': 'Saviciuc',
      'full_name': 'Lucian Saviciuc',
      'photo': 'https://i.pravatar.cc/300?u=lucian_saviciuc',
    },
    {
      'id': '3',
      'name': 'Beniamin',
      'surname': 'Calugaru',
      'full_name': 'Beniamin Calugaru',
      'photo': 'https://i.pravatar.cc/300?u=beniamin_calugaru',
    },
    {
      'id': '4',
      'name': 'David',
      'surname': 'Spaiuc',
      'full_name': 'David Spaiuc',
      'photo': 'https://i.pravatar.cc/300?u=david_spaiuc',
    },
    {
      'id': '5',
      'name': 'Ionel',
      'surname': 'Asandoaie',
      'full_name': 'Ionel Asandoaie',
      'photo': 'https://i.pravatar.cc/300?u=ionel_asandoaie',
    },
    {
      'id': '6',
      'name': 'Daniel',
      'surname': 'Grigoras',
      'full_name': 'Daniel Grigoras',
      'photo': 'https://i.pravatar.cc/300?u=daniel_grigoras',
    },
    {
      'id': '7',
      'name': 'Adrian',
      'surname': 'Amariei',
      'full_name': 'Adrian Amariei',
      'photo': 'https://i.pravatar.cc/300?u=adrian_amariei',
    },
    {
      'id': '8',
      'name': 'Cristi',
      'surname': 'Pascaru',
      'full_name': 'Cristi Pascaru',
      'photo': 'https://i.pravatar.cc/300?u=cristi_pascaru',
    },
    {
      'id': '9',
      'name': 'Niculica',
      'surname': 'Tanasa',
      'full_name': 'Niculica Tanasa',
      'photo': 'https://i.pravatar.cc/300?u=niculica_tanasa',
    },
    {
      'id': '10',
      'name': 'Vasile',
      'surname': 'Sacali',
      'full_name': 'Vasile Sacali',
      'photo': 'https://i.pravatar.cc/300?u=vasile_sacali',
    },
    {
      'id': '11',
      'name': 'Daniel',
      'surname': 'Balcan',
      'full_name': 'Daniel Balcan',
      'photo': 'https://i.pravatar.cc/300?u=daniel_balcan',
    },
  ];
}
