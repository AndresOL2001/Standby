// To parse this JSON data, do
//
//     final acceso = accesoFromJson(jsonString);

import 'dart:convert';

Acceso accesoFromJson(String str) => Acceso.fromJson(json.decode(str));

String accesoToJson(Acceso data) => json.encode(data.toJson());

class Acceso {
    String idAcceso;
    String direccion;
    double precio;
    String nombre;
    int radio;
    String latitudCaseta;
    String longitudCaseta;

    Acceso({
        required this.idAcceso,
        required this.direccion,
        required this.precio,
        required this.nombre,
        required this.radio,
        required this.latitudCaseta,
        required this.longitudCaseta,
    });

    factory Acceso.fromJson(Map<String, dynamic> json) => Acceso(
        idAcceso: json["idAcceso"],
        direccion: json["direccion"],
        precio: json["precio"],
        nombre: json["nombre"],
        radio: json["radio"],
        latitudCaseta: json["latitudCaseta"],
        longitudCaseta: json["longitudCaseta"],
    );

    Map<String, dynamic> toJson() => {
        "idAcceso": idAcceso,
        "direccion": direccion,
        "precio": precio,
        "nombre": nombre,
        "radio": radio,
        "latitudCaseta": latitudCaseta,
        "longitudCaseta": longitudCaseta,
    };
}
