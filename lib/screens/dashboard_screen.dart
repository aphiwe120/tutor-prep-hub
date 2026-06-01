// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson_plan.dart';
import '../widgets/sidebar.dart';
import '../widgets/lesson_card.dart';
import '../widgets/add_lesson_dialog.dart';
import '../services/database_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<LessonPlan> lessons = [];
  bool isLoading = true; 
  String selectedFilter = 'All';
  
  // --- NEW: Search Query State ---
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLessonsFromCloud(); 
  }

  Future<void> _fetchLessonsFromCloud() async {
    setState(() => isLoading = true);
    try {
      final cloudData = await DatabaseService.getLessons();
      setState(() {
        lessons = cloudData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _saveLesson(LessonPlan lesson) async {
    setState(() => isLoading = true); 
    try {
      if (lesson.id == null) {
        await DatabaseService.addLesson(lesson);
      } else {
        await DatabaseService.updateLesson(lesson); 
      }
      await _fetchLessonsFromCloud(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _deleteLesson(String id) async {
    setState(() => isLoading = true);
    try {
      await DatabaseService.deleteLesson(id);
      await _fetchLessonsFromCloud(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      setState(() => isLoading = false);
    }
  }

  // --- UPDATED: Helper Widget for Stats Cards ---
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 16),
              // --- THE FIX ---
              // Wrapping the Column in Expanded tells it to stay strictly inside the card!
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // We also add maxLines and overflow so long titles don't break the layout
                    Text(
                      title, 
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      count, 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Advanced Filtering Logic ---
    final filteredLessons = lessons.where((lesson) {
      // 1. Check if it matches the sidebar category
      final matchesFilter = selectedFilter == 'All' || lesson.subject == selectedFilter;
      
      // 2. Check if it matches the search bar text (ignoring uppercase/lowercase)
      final matchesSearch = searchQuery.isEmpty || 
                            lesson.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            lesson.summary.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prep Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            selectedFilter: selectedFilter,
            onFilterChanged: (newFilter) => setState(() => selectedFilter = newFilter),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NEW: Search Bar & Title Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$selectedFilter Lessons', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onChanged: (value) => setState(() => searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Search notes...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- NEW: Statistics Row ---
                  Row(
                    children: [
                      _buildStatCard('Total Notes', '${lessons.length}', Icons.library_books, Colors.teal),
                      const SizedBox(width: 16),
                      _buildStatCard('Math Lessons', '${lessons.where((l) => l.subject == 'Math').length}', Icons.calculate, Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatCard('Physics Lessons', '${lessons.where((l) => l.subject == 'Physics').length}', Icons.science, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (isLoading) 
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (filteredLessons.isEmpty)
                    const Expanded(child: Center(child: Text("No lesson plans match your search.")))
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450, 
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: filteredLessons.length,
                        itemBuilder: (context, index) {
                          final lesson = filteredLessons[index];
                          return LessonCard(
                            lesson: lesson,
                            onDelete: () => _deleteLesson(lesson.id!),
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddLessonDialog(
                                  onSave: _saveLesson,
                                  lessonToEdit: lesson,
                                ),
                              );
                            },
                          ); 
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddLessonDialog(onSave: _saveLesson),
          );
        },
        label: const Text('New Prep Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}