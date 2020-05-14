import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:auto_construction/src/auto_construction.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'create_file.dart';

//Builder autoConstruction(BuilderOptions options) =>
//    LibraryBuilder(AutoGenerator(), generatedExtension: '.auto.g.dart');
Builder autoConstruction(BuilderOptions options) => __Builder();

Builder autoBuilder(BuilderOptions options) {
  if (options.config["super"] != null) {
    return _Builder(options.config["super"]);
  }
  return _Empty();
}

class _Empty extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) {}

  @override
  Map<String, List<String>> get buildExtensions => {};
}

class _Builder extends Builder {
  CreateFile _createFile;

  String name;
  TypeChecker typeChecker;

  _Builder(this.name) {
    this.typeChecker = TypeChecker.fromUrl(name);
    _createFile = CreateFile.create(
        "./lib/auto_construction/auto_construction_${name.substring(name.indexOf("#") + 1)}.g.dart");
    _createFile.addSuper(name);
  }

  int data = DateTime.now().millisecondsSinceEpoch;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final lib = await buildStep.inputLibrary;
    LibraryReader(lib).classes.forEach((element) {
      if (element.isPublic &&
          !element.isAbstract &&
          typeChecker.isAssignableFrom(element)) {
        _createFile.add(element, buildStep.inputId);
      }
    });
    _createFile.save();
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.$data.g.dart']
      };
}

class __Builder extends Builder {
  List<_Entry<ClassElement>> _elements = [];
  List<_Entry<Element>> _annotatedElements = [];
  Timer _timer;
  String extension = '.auto.g.dart';
  String time = DateTime.now().toIso8601String();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(AutoConstruction);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final lib = await buildStep.inputLibrary;
    var library = LibraryReader(lib);
    library.classes.forEach((element) {
      _elements.add(_Entry(element, buildStep.inputId));
    });
    library.annotatedWith(typeChecker).forEach((element) {
      _annotatedElements.add(_Entry(element.element, buildStep.inputId));
    });
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 2), save);
  }

  void save() {
    _annotatedElements.forEach((element) {
      var path = element._assetId
          .changeExtension("_" + element._element.displayName + extension)
          .path;
      String mSuperUrl =
          "package:${element._assetId.package}${element._assetId.path.substring(3)}#${element._element.displayName}";
      TypeChecker type = TypeChecker.fromUrl(mSuperUrl);
      CreateFile file = CreateFile.create(path);
      file.addSuperElement(element._element, element._assetId);
      _elements.forEach((e) {
        if (e._element.isPublic &&
            !e._element.isAbstract &&
            type.isSuperOf(e._element)) {
          file.add(e._element, e._assetId);
        }
      });
      file.save();
    });
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [time + extension]
      };
}

class _Entry<T> {
  T _element;
  AssetId _assetId;

  _Entry(this._element, this._assetId);
}
