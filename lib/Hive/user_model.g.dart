// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<UserP> {
  @override
  final int typeId = 2;

  @override
  UserP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserP(
      name: fields[0] as String?,
      email: fields[1] as String?,
      image: fields[2] as String?,
      token: fields[3] as String?,
      address: fields[5] as String?,
      phone: fields[6] as String?,
    )..tokenAvailable = fields[4] as bool?;
  }

  @override
  void write(BinaryWriter writer, UserP obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.token)
      ..writeByte(4)
      ..write(obj.tokenAvailable)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
