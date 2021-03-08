import 'package:uni_express/Model/DTO/MetaDataDTO.dart';

class BaseDAO{
  MetaDataDTO _metaDataDTO;

  MetaDataDTO get metaDataDTO => _metaDataDTO;

  set metaDataDTO(MetaDataDTO value) {
    _metaDataDTO = value;
  }
}