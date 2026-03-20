class Participant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<int>
  assignedItems; // List of item IDs assigned to this participant

  Participant({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.assignedItems = const [],
  });

  Participant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<int>? assignedItems,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      assignedItems: assignedItems ?? this.assignedItems,
    );
  }
}
