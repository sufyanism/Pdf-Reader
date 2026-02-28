import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static saveBookmarks(List<int> pages) {
    prefs.setString("bookmarks", jsonEncode(pages));
  }

  static List<int> getBookmarks() {
    final data = prefs.getString("bookmarks");
    if (data == null) return [];
    return List<int>.from(jsonDecode(data));
  }

  static saveLastPage(int page) {
    prefs.setInt("last_page", page);
  }

  static int getLastPage() {
    return prefs.getInt("last_page") ?? 1;
  }

  static saveReadingMode(int mode) {
    prefs.setInt("reading_mode", mode);
  }

  static int getReadingMode() {
    return prefs.getInt("reading_mode") ?? 0;
  }

  static saveFavoriteChapters(List<int> pages) {
    prefs.setString("favorite_chapters", jsonEncode(pages));
  }

  static List<int> getFavoriteChapters() {
    final data = prefs.getString("favorite_chapters");
    if (data == null) return [];
    return List<int>.from(jsonDecode(data));
  }

  /// NEW — Reading time
  static saveTotalReadingSeconds(int seconds) {
    prefs.setInt("total_reading_seconds", seconds);
  }

  static int getTotalReadingSeconds() {
    return prefs.getInt("total_reading_seconds") ?? 0;
  }

  /// NEW — Reading streak
  static saveLastReadDate(String date) {
    prefs.setString("last_read_date", date);
  }

  static String? getLastReadDate() {
    return prefs.getString("last_read_date");
  }

  static saveStreak(int streak) {
    prefs.setInt("reading_streak", streak);
  }

  static int getStreak() {
    return prefs.getInt("reading_streak") ?? 0;
  }

  static saveReadingStreak(int streak) {
    prefs.setInt("reading_streak", streak);
  }

  static int getReadingStreak() {
    return prefs.getInt("reading_streak") ?? 0;
  }

  /// Theme
  static saveTheme(int theme) {
    prefs.setInt("theme_index", theme);
  }

  static int getTheme() {
    return prefs.getInt("theme_index") ?? 0;
  }

  /// Brightness
  static saveBrightness(double value) {
    prefs.setDouble("brightness", value);
  }

  static double getBrightness() {
    return prefs.getDouble("brightness") ?? 1.0;
  }

  /// Font family
  static saveFontFamily(String font) {
    prefs.setString("font_family", font);
  }

  static String getFontFamily() {
    return prefs.getString("font_family") ?? "Default";
  }

  /// Font weight
  static saveFontWeight(int weight) {
    prefs.setInt("font_weight", weight);
  }

  static int getFontWeight() {
    return prefs.getInt("font_weight") ?? 0;
  }
}