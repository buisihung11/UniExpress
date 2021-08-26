class SupplierNoteDTO {
  int supplierStoreId;
  String content;

  SupplierNoteDTO({this.supplierStoreId, this.content});

  factory SupplierNoteDTO.fromJson(dynamic json){
    return SupplierNoteDTO(
        supplierStoreId: json["supplier_store_id"],
        content: json["content"]
    );
  }

  Map<String, dynamic> toJson() {
    return {"supplier_store_id": supplierStoreId, "content": content};
  }
}