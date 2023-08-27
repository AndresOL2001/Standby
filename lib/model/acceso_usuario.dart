// To parse this JSON data, do
//
//     final accesoUsuario = accesoUsuarioFromJson(jsonString);

import 'dart:convert';

List<AccesoUsuario> accesoUsuarioFromJson(String str) => List<AccesoUsuario>.from(json.decode(str).map((x) => AccesoUsuario.fromJson(x)));

String accesoUsuarioToJson(List<AccesoUsuario> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AccesoUsuario {
    String idAcceso;
    String direccion;
    double precio;
    bool garage;
    String nombre;
    int radio;
    bool active;
    String latitudCaseta;
    String longitudCaseta;

    AccesoUsuario({
        required this.idAcceso,
        required this.direccion,
        required this.precio,
        required this.garage,
        required this.nombre,
        required this.radio,
        required this.active,
        required this.latitudCaseta,
        required this.longitudCaseta,
    });

    factory AccesoUsuario.fromJson(Map<String, dynamic> json) => AccesoUsuario(
        idAcceso: json["idAcceso"],
        direccion: json["direccion"],
        precio: json["precio"],
        garage: json["garage"],
        nombre: json["nombre"],
        radio: json["radio"],
        active: json["active"],
        latitudCaseta: json["latitudCaseta"],
        longitudCaseta: json["longitudCaseta"],
    );

    Map<String, dynamic> toJson() => {
        "idAcceso": idAcceso,
        "direccion": direccion,
        "precio": precio,
        "garage": garage,
        "nombre": nombre,
        "radio": radio,
        "active": active,
        "latitudCaseta": latitudCaseta,
        "longitudCaseta": longitudCaseta,
    };
}
