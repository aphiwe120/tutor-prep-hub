// lib/services/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson_plan.dart';

class DatabaseService {
  // A shortcut to talk to Supabase
  static final _supabase = Supabase.instance.client;

  // Function 1: Get all notes from the cloud
  static Future<List<LessonPlan>> getLessons() async {
    // This SQL-like command says: "Get everything from 'lessons' and sort by newest first"
    final data = await _supabase.from('lessons').select().order('created_at', ascending: false);
    
    // Translate the raw database data into our neat LessonPlan objects
    return data.map((item) => LessonPlan.fromJson(item)).toList();
  }

  // Function 2: Save a new note to the cloud
  static Future<void> addLesson(LessonPlan lesson) async {
    // We use the toJson() method we just built to format it perfectly for the database!
    await _supabase.from('lessons').insert(lesson.toJson());
  }
  // Function 3: Delete a note
  static Future<void> deleteLesson(String id) async {
    // Tell Supabase: "Delete from lessons where the ID matches this exact ID"
    await _supabase.from('lessons').delete().eq('id', id);
  }

  // Function 4: Update an existing note
  static Future<void> updateLesson(LessonPlan lesson) async {
    // Tell Supabase: "Update this data where the ID matches"
    await _supabase.from('lessons').update(lesson.toJson()).eq('id', lesson.id!);
  }
}