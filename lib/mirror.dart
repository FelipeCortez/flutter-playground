import 'dart:mirrors';
import 'dart:collection';
import 'dart:io';

class Model {
  Model();

  void action() {}

  List<int> listOfNumbers;
  List<List<int>> listOfListOfNumbers;
  Map<int, List<bool>> mapFromIntToList;
  HashSet<int> setOfNumbers;
  bool tOrF;
  int noDot;
  double decimal;
  String text;
  Symbol sym;

  MiniThing mini;

  @override
  String toString() {
    return "<Model> { mini: $mini\n"
           "        , listOfNumbers: $listOfNumbers\n"
           "        , listOfListOfNumbers: $listOfListOfNumbers\n"
           "        , mapFromIntToList: $mapFromIntToList\n"
           "        , setOfNumbers: $setOfNumbers\n"
           "        , tOrF: $tOrF\n"
           "        , noDot: $noDot\n"
           "        , decimal: $decimal\n"
           "        , text: $text\n"
           "        , sym: $sym\n"
           "        }";
  }
}

class MiniThing {
  bool thingy;

  @override
  String toString() {
    return "<MiniThing> {thingy: $thingy}";
  }
}

var resolvers = {
#dart.core.String: () => "Hello",
#dart.core.int   : () => 12345,
#dart.core.double: () => 123.45,
#dart.core.bool  : () => false,
#dart.core.Symbol: () => #sym,
#dart.core.Map   : (TypeMirror key, TypeMirror value) => createMapOf(key, value),
#dart.core.Set   : (TypeMirror type) => createSetOf(type),
#dart.core.List  : (TypeMirror type) => createListOf(type),
};

dynamic resolveType(TypeMirror type) {
  var resolver = resolvers[type.qualifiedName];

  if (resolver != null) {
    return Function.apply(resolver, type.typeArguments);
  }

  return fillPrime(type as ClassMirror);
}

T create<T>(List<Type> typeParameters) {
  return (reflectType(T, typeParameters) as ClassMirror).newInstance(Symbol(''), []).reflectee as T;
}

List<dynamic> createListOf(TypeMirror type) {
  var list = create<List>([type.reflectedType]);
  list.add(resolveType(type));
  list.add(resolveType(type));
  return list;
}

Set<dynamic> createSetOf(TypeMirror type) {
  var zet = create<LinkedHashSet>([type.reflectedType]);
  zet.add(resolveType(type));
  return zet;
}

Map<dynamic, dynamic> createMapOf(TypeMirror keyType, TypeMirror valueType) {
  var map = create<Map>([keyType.reflectedType, valueType.reflectedType]);
  map[resolveType(keyType)] = resolveType(valueType);
  return map;
}

dynamic fillPrime(ClassMirror clazz) {
  var variables = clazz.declarations.values
      .where((type) => type is VariableMirror)
      .map((type) => type as VariableMirror);

  var mirror = clazz.newInstance(Symbol(''), []);

  variables.forEach((variable) => mirror.setField(variable.simpleName, resolveType(variable.type)));

  return mirror.reflectee;
}

T fill<T>() {
  return fillPrime(reflectClass(T)) as T;
}

main() {
  print(fill<Model>());
}
