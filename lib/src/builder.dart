import 'package:auto_construction/src/auto_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

Builder autoBuilder(BuilderOptions options) => LibraryBuilder(AutoGenerator(),
    generatedExtension: '.${DateTime.now().toIso8601String()}.g.dart');
