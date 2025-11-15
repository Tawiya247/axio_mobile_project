import 'package:dartz/dartz.dart';
import 'package:axio_mobile_project/features/settings/domain/entities/user_settings.dart';

abstract class SettingsRepository {
  Future<Either<Exception, UserSettings>> loadSettings();
  Future<Either<Exception, void>> saveSettings(UserSettings settings);
}
