class LessonModel{
  final String title;
  final String description;
  final String course;
  final String course_code;
  final double progress;
  final int duration;
  final bool completed;

  LessonModel({
    required this.title,
    required this.description,
    required this.course,
    required this.course_code,
    required this.progress,
    required this.duration,
    required this.completed,
  });

  factory LessonModel.fromFirestore(Map<String, dynamic>data){
    return LessonModel(
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        course: data['course'] ?? '',
        course_code: data['course_code'] ?? '',
        progress: (data['progress'] ?? 0).toDouble(),
        duration: data['duration'] ?? 0,
        completed: data['completed'] ?? false,
    );
  }
}