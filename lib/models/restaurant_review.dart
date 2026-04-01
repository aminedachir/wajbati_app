class RestaurantReview {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  const RestaurantReview({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'restaurantId': restaurantId,
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'rating': rating,
        'date': date.toIso8601String(),
      };

  factory RestaurantReview.fromMap(Map<String, dynamic> map) =>
      RestaurantReview(
        id: map['id'],
        restaurantId: map['restaurantId'],
        userId: map['userId'],
        userName: map['userName'],
        comment: map['comment'],
        rating: (map['rating'] as num).toDouble(),
        date: DateTime.parse(map['date']),
      );
}
