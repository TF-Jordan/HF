class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator -> localhost
  static const String apiPrefix = '/cairtech/api';
  static String get apiUrl => '$baseUrl$apiPrefix';

  // ── Auth ──────────────────────────────────────────────────
  static const String register = '/user';
  static const String login = '/user/login';

  // ── Admin ─────────────────────────────────────────────────
  static const String createAdmin = '/admin/create-admin';
  static const String createMember = '/admin/create-member';
  static const String createInCharge = '/admin/create-InCharge';
  static const String createBbc = '/admin/create-bbc';
  static const String createLeader = '/admin/create-leader';

  // ── Members ───────────────────────────────────────────────
  static const String members = '/member';
  static String memberById(String id) => '/member/$id';
  static String membersByBbc(String id) => '/member/bibleclub/$id';
  static String changeMemberStatus(String id, String status) =>
      '/member/$id/$status';

  // ── InCharge ──────────────────────────────────────────────
  static const String inCharges = '/inCharge';
  static const String inChargeCreateMember = '/inCharge/member';

  // ── Roles ─────────────────────────────────────────────────
  static const String roles = '/role';
}
