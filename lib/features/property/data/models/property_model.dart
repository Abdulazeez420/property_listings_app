class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> tags;
  final String status;
  final List<String> images;
  final DateTime postedDate;
  final bool? isFavorite;

  final int areaSqFt;
  final int bedrooms;
  final int bathrooms;
  final String currency;

  final String agentName;
  final String agentContact;
  final String agentEmail;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.tags,
    required this.status,
    required this.images,
    required this.postedDate,
    this.isFavorite,
    required this.areaSqFt,
    required this.bedrooms,
    required this.bathrooms,
    required this.currency,
    required this.agentName,
    required this.agentContact,
    required this.agentEmail,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'] is Map<String, dynamic> ? json['location'] : null;
    final formattedLocation = locationData != null
        ? '${locationData['address'] ?? ''}, ${locationData['city'] ?? ''}'.trim()
        : '';

    final agentData = json['agent'] ?? {};

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: formattedLocation,
      tags: List<String>.from((json['tags'] ?? []).map((e) => e?.toString() ?? '')),
      status: (json['status']?.toString() ?? 'available').toLowerCase(),
      images: List<String>.from((json['images'] ?? []).map((e) => e?.toString() ?? '')),
      postedDate: json['dateListed'] != null
          ? DateTime.tryParse(json['dateListed'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool?,
      areaSqFt: (json['areaSqFt'] ?? 0).toInt(),
      bedrooms: (json['bedrooms'] ?? 0).toInt(),
      bathrooms: (json['bathrooms'] ?? 0).toInt(),
      currency: json['currency']?.toString() ?? 'USD',
      agentName: agentData['name']?.toString() ?? '',
      agentContact: agentData['contact']?.toString() ?? '',
      agentEmail: agentData['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'location': location,
        'tags': tags,
        'status': status,
        'images': images,
        'dateListed': postedDate.toIso8601String(),
        'isFavorite': isFavorite,
        'areaSqFt': areaSqFt,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'currency': currency,
        'agent': {
          'name': agentName,
          'contact': agentContact,
          'email': agentEmail,
        }
      };

  static Property empty() => Property(
        id: '',
        title: '',
        description: '',
        price: 0,
        location: '',
        tags: [],
        status: 'available',
        images: [],
        postedDate: DateTime.now(),
        isFavorite: false,
        areaSqFt: 0,
        bedrooms: 0,
        bathrooms: 0,
        currency: 'USD',
        agentName: '',
        agentContact: '',
        agentEmail: '',
      );

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    List<String>? tags,
    String? status,
    List<String>? images,
    DateTime? postedDate,
    bool? isFavorite,
    int? areaSqFt,
    int? bedrooms,
    int? bathrooms,
    String? currency,
    String? agentName,
    String? agentContact,
    String? agentEmail,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      images: images ?? this.images,
      postedDate: postedDate ?? this.postedDate,
      isFavorite: isFavorite ?? this.isFavorite,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      currency: currency ?? this.currency,
      agentName: agentName ?? this.agentName,
      agentContact: agentContact ?? this.agentContact,
      agentEmail: agentEmail ?? this.agentEmail,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Property && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
