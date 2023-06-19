import 'dart:convert';

NuevoUsuario nuevoUsuarioFromJson(String str) => NuevoUsuario.fromJson(json.decode(str));

String nuevoUsuarioToJson(NuevoUsuario data) => json.encode(data.toJson());

class NuevoUsuario {
    String idUsuario;
    String numeroSerie;
    String nombreCompleto;
    String calle;
    String numeroCasa;
    String celular;
    String contrasena;

    NuevoUsuario({
        required this.idUsuario,
        required this.numeroSerie,
        required this.nombreCompleto,
        required this.calle,
        required this.numeroCasa,
        required this.celular,
        required this.contrasena,
    });

    factory NuevoUsuario.fromJson(Map<String, dynamic> json) => NuevoUsuario(
        idUsuario: json["idUsuario"],
        numeroSerie: json["numeroSerie"],
        nombreCompleto: json["nombreCompleto"],
        calle: json["calle"],
        numeroCasa: json["numeroCasa"],
        celular: json["celular"],
        contrasena: json["contraseña"],
    );

    Map<String, dynamic> toJson() => {
        "idUsuario": idUsuario,
        "numeroSerie": numeroSerie,
        "nombreCompleto": nombreCompleto,
        "calle": calle,
        "numeroCasa": numeroCasa,
        "celular": celular,
        "contraseña": contrasena,
    };
}
