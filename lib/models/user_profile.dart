import "package:flutter/foundation.dart";

class UserProfile {
  const UserProfile({
    this.id,
    this.plan = 'free',
    this.isActive = true,
    this.isVerified = false,
    this.displayName = 'Alex',
    this.fullName = 'Alex Johnson',
    this.address = 'New York, 5th Avenue 130',
    this.email = 'alex@example.com',
    this.phone = '+1 555 010 2030',
    this.localeCode = 'en',
    this.avatarPath,
  });

  final int? id;
  final String plan;
  final bool isActive;
  final bool isVerified;
  final String displayName;
  final String fullName;
  final String address;
  final String email;
  final String phone;
  final String localeCode;
  final String? avatarPath;

  UserProfile copyWith({
    int? id,
    String? plan,
    bool? isActive,
    bool? isVerified,
    String? displayName,
    String? fullName,
    String? address,
    String? email,
    String? phone,
    String? localeCode,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      localeCode: localeCode ?? this.localeCode,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
    );
  }

  factory UserProfile.fromStorage(Map<String, dynamic> json) {
    return UserProfile(
      id: _readInt(json['id']),
      plan: json['plan']?.toString() ?? 'free',
      isActive: _readBool(json['isActive']) ?? true,
      isVerified: _readBool(json['isVerified']) ?? false,
      displayName: json['displayName'] as String? ?? 'Alex',
      fullName: json['fullName'] as String? ?? 'Alex Johnson',
      address: json['address'] as String? ?? 'New York, 5th Avenue 130',
      email: json['email'] as String? ?? 'alex@example.com',
      phone: json['phone'] as String? ?? '+1 555 010 2030',
      localeCode: json['localeCode'] as String? ?? 'en',
      avatarPath: json['avatarPath'] as String?,
    );
  }

  factory UserProfile.fromBackend(Map<String, dynamic> json) {
    final map = json.containsKey('profile') && json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : Map<String, dynamic>.from(json);
    return UserProfile(
      id: _readInt(map['id']),
      plan: map['plan']?.toString() ?? 'free',
      isActive: _readBool(map['is_active'] ?? map['isActive']) ?? true,
      isVerified: _readBool(map['is_verified'] ?? map['isVerified']) ?? false,
      displayName: map['display_name']?.toString() ??
          map['displayName']?.toString() ??
          'Alex',
      fullName: map['full_name']?.toString() ??
          map['fullName']?.toString() ??
          'Alex Johnson',
      address: map['address']?.toString() ?? 'New York, 5th Avenue 130',
      email: map['email']?.toString() ?? 'alex@example.com',
      phone: map['phone']?.toString() ?? '+1 555 010 2030',
      localeCode: map['locale_code']?.toString() ??
          map['localeCode']?.toString() ??
          'en',
      avatarPath: map['avatar_path']?.toString() ??
          map['avatarPath']?.toString(),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'id': id,
      'plan': plan,
      'isActive': isActive,
      'isVerified': isVerified,
      'displayName': displayName,
      'fullName': fullName,
      'address': address,
      'email': email,
      'phone': phone,
      'localeCode': localeCode,
      'avatarPath': avatarPath,
    };
  }

  Map<String, dynamic> toBackend() {
    return {
      'id': id,
      'plan': plan,
      'is_active': isActive,
      'is_verified': isVerified,
      'display_name': displayName,
      'full_name': fullName,
      'address': address,
      'email': email,
      'phone': phone,
      'locale_code': localeCode,
      'avatar_path': avatarPath,
    };
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return null;
  }
}
