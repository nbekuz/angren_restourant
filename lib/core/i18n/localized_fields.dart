String localizedField(
  String locale, {
  required String? uz,
  String? ru,
  String? en,
  String fallback = '',
}) {
  final uzValue = (uz ?? '').trim();
  final ruValue = (ru ?? '').trim();
  final enValue = (en ?? '').trim();
  if (locale.startsWith('ru') && ruValue.isNotEmpty) return ruValue;
  if (locale.startsWith('en') && enValue.isNotEmpty) return enValue;
  if (uzValue.isNotEmpty) return uzValue;
  if (ruValue.isNotEmpty) return ruValue;
  if (enValue.isNotEmpty) return enValue;
  return fallback;
}

List<String> localizedStringList(
  String locale, {
  List<dynamic>? uz,
  List<dynamic>? ru,
  List<dynamic>? en,
}) {
  List<String> clean(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  final uzList = clean(uz);
  final ruList = clean(ru);
  final enList = clean(en);
  if (locale.startsWith('ru') && ruList.isNotEmpty) return ruList;
  if (locale.startsWith('en') && enList.isNotEmpty) return enList;
  if (uzList.isNotEmpty) return uzList;
  if (ruList.isNotEmpty) return ruList;
  if (enList.isNotEmpty) return enList;
  return const [];
}
