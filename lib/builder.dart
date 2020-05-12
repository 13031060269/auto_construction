import 'package:auto_construction/auto_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

Builder autoBuilder(BuilderOptions options) {
  return LibraryBuilder(AutoGenerator());
}
