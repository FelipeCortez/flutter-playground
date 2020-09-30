import 'dart:mirrors';
import 'dart:io';
import 'amodel.dart';

main() {
  // InstanceMirror myClassInstanceMirror = reflect(ACounter);
  // ClassMirror MyClassMirror = myClassInstanceMirror.type;
  // Map<String, MethodMirror> map = MyClassMirror.methods;

  // print("map = ${map}");
  var im = reflectClass(
      ACounter); // Retrieve the InstanceMirror of some class instance.
    VariableMirror vm = im.declarations.values.first;
    TypeMirror tm = vm.type;
  print(tm.typeArguments.first.reflectedType);
}
