import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/member_repository.dart';
import '../../data/repositories/bible_club_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/incharge_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/member_model.dart';
import '../../data/models/incharge_model.dart';

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
    if (e.toString().contains('401')) return 'Email ou mot de passe incorrect';
    if (e.toString().contains('409')) return 'Cet email existe déjà';
    if (e.toString().contains('SocketException')) {
      return 'Impossible de se connecter au serveur';
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
