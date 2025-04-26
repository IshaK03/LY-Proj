import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateHash(String name) {
  var bytes = utf8.encode(name);
  var digest = sha256.convert(bytes);
  return digest.toString().substring(0, 8);
}
