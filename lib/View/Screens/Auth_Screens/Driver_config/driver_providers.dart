import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverConfigDropDownProvider =
    StateProvider.autoDispose<String?>((ref) => "Small Truck");
final driverConfigIsLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
