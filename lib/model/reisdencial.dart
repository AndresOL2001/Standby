class Residencial {
    String idResidencial;
    dynamic nombre;
    String direccion;
    String numeroSerie;
    String latitudResidencial;
    String longitudResidencial;

    Residencial({
        required this.idResidencial,
        this.nombre,
        required this.direccion,
        required this.numeroSerie,
        required this.latitudResidencial,
        required this.longitudResidencial,
    });

    factory Residencial.fromJson(Map<String, dynamic> json) => Residencial(
        idResidencial: json["idResidencial"],
        nombre: json["nombre"],
        direccion: json["direccion"],
        numeroSerie: json["numeroSerie"],
        latitudResidencial: json["latitudResidencial"],
        longitudResidencial: json["longitudResidencial"],
    );

    Map<String, dynamic> toJson() => {
        "idResidencial": idResidencial,
        "nombre": nombre,
        "direccion": direccion,
        "numeroSerie": numeroSerie,
        "latitudResidencial": latitudResidencial,
        "longitudResidencial": longitudResidencial,
    };
}