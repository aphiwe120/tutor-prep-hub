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

  // UPDATED: We removed "Expanded" and gave it a minimum width so it never squishes!
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 200, // Fixed minimum width
      margin: const EdgeInsets.only(right: 16, bottom: 16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
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
    // --- THE RESPONSIVE MAGIC ---
    // If the screen is wider than 800 pixels, it's a desktop. Otherwise, mobile!
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final filteredLessons = lessons.where((lesson) {
      final matchesFilter = selectedFilter == 'All' || lesson.subject == selectedFilter;
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
      // NEW: A Drawer (Hamburger menu) that ONLY appears on mobile screens
      drawer: isDesktop ? null : Drawer(
        child: Sidebar(
          selectedFilter: selectedFilter,
          onFilterChanged: (newFilter) {
            setState(() => selectedFilter = newFilter);
            Navigator.pop(context); // Automatically close the drawer when you tap a subject
          },
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The permanent sidebar ONLY renders if we are on a desktop
          if (isDesktop)
            Sidebar(
              selectedFilter: selectedFilter,
              onFilterChanged: (newFilter) => setState(() => selectedFilter = newFilter),
            ),
          
          Expanded(
            child: Padding(
              // Slightly smaller padding on mobile so you get more screen space
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UPDATED: Using "Wrap" allows the search bar to drop to the next line on small screens
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('$selectedFilter Lessons', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: isDesktop ? 300 : double.infinity, // Full width search bar on mobile
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

                  // UPDATED: A horizontally scrollable row for stats so they never get squished
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCard('Total Notes', '${lessons.length}', Icons.library_books, Colors.teal),
                        _buildStatCard('Math Lessons', '${lessons.where((l) => l.subject == 'Math').length}', Icons.calculate, Colors.blue),
                        _buildStatCard('Physics Lessons', '${lessons.where((l) => l.subject == 'Physics').length}', Icons.science, Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (isLoading) 
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (filteredLessons.isEmpty)
                    const Expanded(child: Center(child: Text("No lesson plans match your search.")))
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450, 
                          // A slightly taller card aspect ratio on mobile to fit the text better
                          childAspectRatio: isDesktop ? 1.2 : 0.9,
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