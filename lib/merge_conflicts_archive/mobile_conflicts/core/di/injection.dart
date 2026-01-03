import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/datasources/remote/auth_service.dart';
import '../../data/datasources/remote/firebase_service.dart';
import '../../data/datasources/local/hive_service.dart';
import '../../data/datasources/local/preferences_service.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/ai_service.dart';

/// Riverpod providers used across the app. Keep registrations here.

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.read(apiServiceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(apiServiceProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(ref.read(apiServiceProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.read(messageRepositoryProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});
