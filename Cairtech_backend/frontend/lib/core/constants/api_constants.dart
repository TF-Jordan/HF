import 'dart:io' show Platform;

class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────
  static const String _port = '8080';

  /// Android emulator uses 10.0.2.2 to reach host's localhost.
  /// Desktop (Linux, macOS, Windows) uses localhost directly.
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port';
    return 'http://localhost:$_port';
  }

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
  static const String rolesInit = '/role/init';
  static String roleByName(String name) => '/role/name/$name';
  static String rolesByUser(String userId) => '/role/user/$userId';

  // ── Bible Clubs (CRUD) ──────────────────────────────────
  static const String bibleClubs = '/bbc';
  static String bibleClubById(String id) => '/bbc/$id';
  static String bibleClubByCode(String code) => '/bbc/code/$code';

  // ── Daily Verse ─────────────────────────────────────────
  static const String dailyVerse = '/daily-verse';
  static const String dailyVerseLatest = '/daily-verse/latest';
  static String dailyVerseById(String id) => '/daily-verse/$id';

  // ── Publications ────────────────────────────────────────
  static const String publications = '/publication';
  static String publicationById(String id) => '/publication/$id';
  static String publicationsByStatus(String status) => '/publication/status/$status';
  static String publicationValidate(String id) => '/publication/$id/validate';

  // ── Notifications ───────────────────────────────────────
  static const String notifications = '/notification';
  static String notificationById(String id) => '/notification/$id';
  static String notificationsByRecipient(String r) => '/notification/recipient/$r';
  static String notificationsUnread(String r) => '/notification/recipient/$r/unread';
  static String notificationMarkRead(String id) => '/notification/$id/read';

  // ── School Year ─────────────────────────────────────────
  static const String schoolYears = '/school-year';
  static const String schoolYearCurrent = '/school-year/current';
  static String schoolYearById(String id) => '/school-year/$id';

  // ── Activity Reports ────────────────────────────────────
  static const String activityReports = '/activity-report';
  static String activityReportById(String id) => '/activity-report/$id';
  static String activityReportValidate(String id) => '/activity-report/$id/validate';

  // ── Activity Types ──────────────────────────────────────
  static const String activityTypes = '/activity-type';
  static String activityTypeById(String id) => '/activity-type/$id';

  // ── Permissions ─────────────────────────────────────────
  static const String permissions = '/permission';
  static String permissionById(String id) => '/permission/$id';
}
