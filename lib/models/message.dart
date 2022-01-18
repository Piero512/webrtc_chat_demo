import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final DateTime arrival;
  final String from;
  final String message;

  ChatMessage({
    required this.arrival,
    required this.from,
    required this.message,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        arrival: DateTime.tryParse(json['arrival']) ?? DateTime.now(),
        from: json['from'] as String,
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() =>
      {'arrival': arrival.toIso8601String(), 'from': from, 'message': message};

  @override
  List<Object?> get props => [arrival, from, message];
}
