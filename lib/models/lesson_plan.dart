// lib/models/lesson_plan.dart

class LessonPlan {
  final String? id; // It has a question mark because brand new lessons don't have an ID until the database assigns one!
  final String title;
  final String subject;
  final String summary;
  final List<String> links;
  final DateTime? lessonDate;
  
  LessonPlan({
    this.id,
    required this.title, 
    required this.subject, 
    required this.summary,
    this.links = const [],
    this.lessonDate, 
  });

  // 1. Translates FROM Supabase into our Flutter App
  factory LessonPlan.fromJson(Map<String, dynamic> json) {
    return LessonPlan(
      id: json['id'].toString(),
      title: json['title'],
      subject: json['subject'],
      summary: json['summary'],
      // We have to tell Flutter to explicitly treat the database array as a List of Strings
      links: List<String>.from(json['links'] ?? []),
      lessonDate: json['lesson_date'] != null ? DateTime.parse(json['lesson_date']) : null, 
    );
  }

  // 2. Translates FROM our Flutter App into Supabase
  Map<String, dynamic> toJson() {
    return {
      // Notice we don't send the ID. Supabase creates that automatically!
      'title': title,
      'subject': subject,
      'summary': summary,
      'links': links,
      'lesson_date': lessonDate?.toIso8601String().split('T').first,
    };
  }
}