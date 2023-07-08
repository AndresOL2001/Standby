import 'dart:convert';

Acceso accesoFromJson(String str) => Acceso.fromJson(json.decode(str));

String accesoToJson(Acceso data) => json.encode(data.toJson());

class Acceso {
    String idAcceso;
    String direccion;
    dynamic precio;
    dynamic nombre;
    String latitudCaseta;
    String longitudCaseta;
    bool isSelected;

    Acceso({
        required this.idAcceso,
        required this.direccion,
        required this.precio,
        required this.nombre,
        required this.latitudCaseta,
        required this.longitudCaseta,
        this.isSelected = false
    });

    factory Acceso.fromJson(Map<String, dynamic> json) => Acceso(
        idAcceso: json["idAcceso"],
        direccion: json["direccion"],
        precio: json["precio"],
        nombre: json["nombre"],
        latitudCaseta: json["latitudCaseta"],
        longitudCaseta: json["longitudCaseta"],
    );

    Map<String, dynamic> toJson() => {
        "idAcceso": idAcceso,
        "direccion": direccion,
        "precio": precio,
        "nombre": nombre,
        "latitudCaseta": latitudCaseta,
        "longitudCaseta": longitudCaseta,
    };
}