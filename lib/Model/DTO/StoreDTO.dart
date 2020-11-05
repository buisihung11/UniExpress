class StoreDTO{
  int id;
  String name;
  String location;

  StoreDTO({this.id, this.name, this.location});

  factory StoreDTO.fromJson(dynamic json){
    return StoreDTO(
      id: json['id'],
      name: json['name'],
      location: json['address']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "address": location
    };
  }
}