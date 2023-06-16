import 'dart:convert';

NuevoUsuario nuevoUsuarioFromJson(String str) => NuevoUsuario.fromJson(json.decode(str));

String nuevoUsuarioToJson(NuevoUsuario data) => json.encode(data.toJson());

class NuevoUsuario {
    String numeroSerie;
    String nombreCompleto;
    String calle;
    String numeroCasa;
    String celular;
    String contrasena;

    NuevoUsuario({
        required this.numeroSerie,
        required this.nombreCompleto,
        required this.calle,
        required this.numeroCasa,
        required this.celular,
        required this.contrasena,
    });

    factory NuevoUsuario.fromJson(Map<String, dynamic> json) => NuevoUsuario(
        numeroSerie: json["numeroSerie"],
        nombreCompleto: json["nombreCompleto"],
        calle: json["calle"],
        numeroCasa: json["numeroCasa"],
        celular: json["celular"],
        contrasena: json["contraseña"],
    );

    Map<String, dynamic> toJson() => {
        "numeroSerie": numeroSerie,
        "nombreCompleto": nombreCompleto,
        "calle": calle,
        "numeroCasa": numeroCasa,
        "celular": celular,
        "contraseña": contrasena,
    };
}
