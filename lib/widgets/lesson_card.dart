// lib/widgets/lesson_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lesson_plan.dart';

class LessonCard extends StatelessWidget {
  final LessonPlan lesson;
  final VoidCallback onDelete; // Added delete trigger
  final VoidCallback onEdit;   // Added edit trigger

  const LessonCard({
    super.key, 
    required this.lesson,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // InkWell makes the whole card clickable!
        onTap: onEdit, // Click the card to edit
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        if (lesson.lessonDate != null)
                          Text('Taught on: ${lesson.lessonDate!.month}/${lesson.lessonDate!.day}/${lesson.lessonDate!.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(lesson.subject, style: const TextStyle(fontSize: 12)),
                    backgroundColor: lesson.subject == 'Math' ? Colors.blue[100] : Colors.orange[100],
                  ),
                  // The New Trash Can!
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  )
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(lesson.summary, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ),
              ),
              if (lesson.links.isNotEmpty) ...[
                const Divider(),
                Wrap(
                  spacing: 8,
                  children: lesson.links.map((link) {
                    return ActionChip(
                      avatar: const Icon(Icons.link, size: 16),
                      label: Text(link.length > 20 ? '${link.substring(0, 20)}...' : link, style: const TextStyle(fontSize: 12)),
                      onPressed: () async {
                        final Uri url = Uri.parse(link.startsWith('http') ? link : 'https://$link');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                    );
                  }).toList(),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}