import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:auto_construction/src/auto_construction.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import 'create_file.dart';

class AutoGenerator extends GeneratorForAnnotation<AutoConstruction> {
  CreateFile _createFile = CreateFile(
      File("./lib/auto_construction/auto_construction_create.g.dart"));

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
//    _createFile.add(element, buildStep.inputId);
    return null;
  }
}
