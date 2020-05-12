import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:auto_construction/auto_construction.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

class AutoGenerator extends GeneratorForAnnotation<AutoConstruction> {
  Timer timer;
  HashSet<String> imports = HashSet();
  HashSet<String> names = HashSet();
  File file = File("./lib/auto_create.dart");

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    imports.add(
        '''import "package:${buildStep.inputId.path.replaceAll("lib", buildStep.inputId.package)}";\n''');
    names.add(element.displayName);
    save();
    return null;
  }

  save() {
    timer?.cancel();
    timer = Timer(Duration(seconds: 5), () {
      StringBuffer sb = StringBuffer();
      imports.forEach((element) {
        sb.write(element);
      });
      sb.writeln("Type _typeOf<T>() => T;");
      sb.writeln("T autoCreate<T>() {");
      sb.writeln("\tvar result;");
      sb.writeln("\tswitch (_typeOf<T>()) {");
      names.forEach((element) {
        sb.writeln("\t\tcase $element:");
        sb.writeln("\t\t\tresult = $element();");
        sb.writeln("\t\t\tbreak;");
      });
      sb.writeln("\t\tdefault:");
      sb.writeln("\t\t\tresult = null;");
      sb.writeln("\t\t\tbreak;");
      sb.writeln("\t}");
      sb.writeln("\treturn result;");
      sb.writeln("}");
      file.writeAsStringSync(sb.toString());
    });
  }
}
