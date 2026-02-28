import '../entities/cropz_profile.dart';
import '../repositories/cropz_card_repository.dart';

class GetCropzProfiles {
  const GetCropzProfiles(this.repository);

  final CropzCardRepository repository;

  Future<List<CropzProfile>> call() {
    return repository.getAllProfiles();
  }
}
