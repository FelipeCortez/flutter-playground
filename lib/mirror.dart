import 'dart:mirrors';
import 'dart:collection';
import 'dart:io';

class Model {
  Model();

  void action() {}

  List<int> listOfNumbers;
  List<List<int>> listOfListOfNumbers;
  Set<int> setOfNumbers;
  bool tOrF;
  int noDot;
  double decimal;
  String text;
  Symbol sym;
}

class MiniThing {
  int thingy;
}

var resolvers = {
  #dart.core.String: () => "Hello",
  #dart.core.int   : () => 12345,
  #dart.core.double: () => 123.45,
  #dart.core.bool  : () => false,
  #dart.core.Symbol: () => #sym,
  #dart.core.Set   : (TypeMirror x) => createSetOf(x),
  #dart.core.List  : (TypeMirror x) => createListOf(x),
};

dynamic resolveType(TypeMirror x) {
  return Function.apply(resolvers[x.qualifiedName], x.typeArguments);
}

List<dynamic> createListOf(TypeMirror x) {
  var list = (reflectType(List, [x.reflectedType]) as ClassMirror)
      .newInstance(Symbol(''), []).reflectee;
  list.add(resolveType(x));
  list.add(resolveType(x));
  return list;
}

Set<dynamic> createSetOf(TypeMirror x) {
  var zet = (reflectType(LinkedHashSet, [x.reflectedType]) as ClassMirror)
      .newInstance(Symbol(''), []).reflectee;
  zet.add(resolveType(x));
  return zet;
}

T fill<T>() {
  var clazz = reflectClass(T);

  var variables = clazz.declarations.values
      .where((x) => x is VariableMirror)
      .map((x) => x as VariableMirror);

  var mirror = clazz.newInstance(Symbol(''), []);

  variables.forEach((variable) =>
  mirror.setField(variable.simpleName, resolveType(variable.type)));

  return mirror.reflectee as T;
}

main() {
  var filledModel = fill<Model>();

  print(filledModel.listOfListOfNumbers);
  print(filledModel.listOfNumbers);
  print(filledModel.setOfNumbers);
  print(filledModel.noDot);
  print(filledModel.decimal);
  print(filledModel.text);
  print(filledModel.tOrF);
  print(filledModel.sym);
}
