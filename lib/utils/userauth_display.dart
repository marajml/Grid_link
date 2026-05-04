/// Shared helpers for [userauth] rows from Supabase.
///
/// Signup stores `profile_image_url`; older code used `profile_url`. Company
/// accounts use `company_logo_url` for the brand mark.
String? userauthAvatarUrl(Map<String, dynamic>? row) {
  if (row == null) return null;
  final role = row['role']?.toString();
  if (role == 'Company') {
    final logo = row['company_logo_url'];
    if (logo is String && logo.trim().isNotEmpty) return logo.trim();
  }
  for (final key in ['profile_image_url', 'profile_url']) {
    final v = row[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  if (role == 'Company') {
    final logo = row['company_logo_url'];
    if (logo is String && logo.trim().isNotEmpty) return logo.trim();
  }
  return null;
}
