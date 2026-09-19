class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Future<void> init() async {
    // Dummy initialization
  }
}

final profileService = ProfileService();
