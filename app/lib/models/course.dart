class Poster {
  final String publicId;
  final String url;

  Poster({
    required this.publicId,
    required this.url,
  });

  factory Poster.fromMap(Map<String, dynamic> map) {
    return Poster(
      publicId: map['public_id'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String createdBy;
  final int views;
  final int numOfVideos;
  final String createdAt;
  final Poster poster;
  List<Lecture> lectures;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.views,
    required this.numOfVideos,
    required this.createdAt,
    required this.poster,
    this.lectures = const [], // Initialize with an empty list
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      views: map['views'] ?? 0,
      numOfVideos: map['numOfVideos'] ?? 0,
      createdAt: map['createdAt'] ?? '',
      poster: Poster.fromMap(map['poster'] ?? {}),
      lectures: [],
    );
  }
}

class Lecture {
  final String id;
  final String title;
  final String description;
  final String videoUrl;

  Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['video']['url'] ?? '', // Extract the video URL
    );
  }
}
