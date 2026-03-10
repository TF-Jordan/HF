import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/member_repository.dart';
import '../../data/repositories/bible_club_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/incharge_repository.dart';
import '../../data/repositories/daily_verse_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/publication_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/member_model.dart';
import '../../data/models/bible_club_model.dart';
import '../../data/models/incharge_model.dart';
import '../../data/models/daily_verse_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/publication_model.dart';

// ── Core Services ───────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiServiceProvider));
});

// ── Repositories ────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.read(apiServiceProvider));
});

final bibleClubRepositoryProvider = Provider<BibleClubRepository>((ref) {
  return BibleClubRepository(ref.read(apiServiceProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiServiceProvider));
});

final inchargeRepositoryProvider = Provider<InchargeRepository>((ref) {
  return InchargeRepository(ref.read(apiServiceProvider));
});

final dailyVerseRepositoryProvider = Provider<DailyVerseRepository>((ref) {
  return DailyVerseRepository(ref.read(apiServiceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiServiceProvider));
});

final publicationRepositoryProvider = Provider<PublicationRepository>((ref) {
  return PublicationRepository(ref.read(apiServiceProvider));
});

// ── Auth State ──────────────────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final AuthService _authService;

  AuthNotifier(this._authRepo, this._authService)
      : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final claims = await _authService.getCurrentUser();
      if (claims != null) {
        final user = UserModel.fromJson(claims);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
    }
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.login(email, password);
      final claims = await _authService.getCurrentUser();
      final user = claims != null ? UserModel.fromJson(claims) : null;
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _parseError(e),
      );
    }
  }

  Future<void> register(String email, String password, String phone) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.register(
        email: email,
        password: password,
        phoneNumber: phone,
      );
      final claims = await _authService.getCurrentUser();
      final user = claims != null ? UserModel.fromJson(claims) : null;
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _parseError(e),
      );
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    // Try to extract HTTP status code from DioException
    int? statusCode;
    try {
      statusCode = (e as dynamic).response?.statusCode as int?;
    } catch (_) {}

    if (statusCode == 401 || msg.contains('401')) {
      return 'Email ou mot de passe incorrect';
    }
    if (statusCode == 409 || msg.contains('409')) {
      return 'Cet email existe déjà';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Impossible de se connecter au serveur';
    }
    if (statusCode == 500 || msg.contains('500')) {
      return 'Erreur serveur. Réessayez plus tard.';
    }
    return 'Une erreur est survenue';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(authServiceProvider),
  );
});

// ── Members State ───────────────────────────────────────────

final allMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final repo = ref.read(memberRepositoryProvider);
  return repo.getAllMembers();
});

final membersByBbcProvider =
    FutureProvider.family<List<MemberModel>, String>((ref, bbcId) async {
  final repo = ref.read(memberRepositoryProvider);
  return repo.getMembersByBbc(bbcId);
});

// ── InCharge State ──────────────────────────────────────────

final allInChargesProvider = FutureProvider<List<InchargeModel>>((ref) async {
  final repo = ref.read(inchargeRepositoryProvider);
  return repo.getAllInCharges();
});

// ── Bible Clubs State ───────────────────────────────────────

final allBibleClubsProvider = FutureProvider<List<BibleClubModel>>((ref) async {
  final repo = ref.read(bibleClubRepositoryProvider);
  return repo.getAllBibleClubs();
});

// ── Daily Verse State ───────────────────────────────────────

final latestVerseProvider = FutureProvider<DailyVerseModel?>((ref) async {
  try {
    final repo = ref.read(dailyVerseRepositoryProvider);
    return await repo.getLatest();
  } catch (_) {
    return null;
  }
});

final allVersesProvider = FutureProvider<List<DailyVerseModel>>((ref) async {
  final repo = ref.read(dailyVerseRepositoryProvider);
  return repo.getAll();
});

// ── Notifications State ─────────────────────────────────────

final allNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getAll();
});

final unreadNotificationsProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, recipient) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getUnread(recipient);
});

// ── Publications State ──────────────────────────────────────

final allPublicationsProvider = FutureProvider<List<PublicationModel>>((ref) async {
  final repo = ref.read(publicationRepositoryProvider);
  return repo.getAll();
});
