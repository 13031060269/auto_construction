import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

class CreateFile {
  Timer? _timer;
  File _file;
  String? superName;

  CreateFile(this._file) {
    if (_file.existsSync()) {
      _file.delete();
    }
  }

  factory CreateFile.create(String file) => CreateFile(File(file));

  HashSet<String> _imports = HashSet();
  HashSet<String> _names = HashSet();

  addSuperElement(Element element, AssetId assetId) {
    _imports.add(
        '''import "package:${assetId.path.replaceAll("lib", assetId.package)}";\n''');
    superName = element.displayName;
  }

  add(Element element, AssetId assetId) {
    _imports.add(
        '''import "package:${assetId.path.replaceAll("lib", assetId.package)}";\n''');
    _names.add(element.displayName);
  }

  save() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 2), _save);
  }

  _save() {
    _file.parent.createSync(recursive: true);
    StringBuffer sb = StringBuffer();
    sb.writeln(
        '''import 'package:auto_construction/auto_construction.dart';''');
    _imports.forEach((element) {
      sb.write(element);
    });

    sb.write("T auto${superName}Create<T");
    if (superName != null) {
      sb.write(" extends $superName");
    }
    sb.write(">() {");
    sb.writeln();
    sb.writeln("\tvar result;");
    sb.writeln("\tvar type = autoTypeOf<T>();");

    sb.writeln("\tswitch (type) {");
    _names.forEach((element) {
      sb.writeln("\t\tcase $element:");
      sb.writeln("\t\t\tresult = $element();");
      sb.writeln("\t\t\tbreak;");
    });
    sb.writeln("\t\tdefault:");
    sb.writeln("\t\t\tthrow Exception(\"\$type 无法实例化\");");
    sb.writeln("\t}");
    sb.writeln("\treturn result;");
    sb.writeln("}");
    _file.writeAsStringSync(sb.toString());
  }
}
