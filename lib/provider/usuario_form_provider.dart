import 'package:flutter/material.dart';

import '../model/nuevo_usuario.dart';

class UserFormProvider extends ChangeNotifier{

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  NuevoUsuario? nuevoUsuario;
  bool _isLoading = false;

  UserFormProvider();

  bool get isLoading => _isLoading;
  
  set isLoading(bool value ){
    _isLoading = value;
    notifyListeners();
  }

  void updateNuevoUsuario(NuevoUsuario newUser) {
    nuevoUsuario = newUser;
    notifyListeners();
  }

  bool isValidForm(){
    return formKey.currentState?.validate() ?? false;
  }

}