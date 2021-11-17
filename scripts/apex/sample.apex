String ciperText = SecurityUtils.encryptUrl('00QN000000AQMNPMA5');
system.debug('ciperText : ' + ciperText);
system.debug(' Decrypted Data : ' + SecurityUtils.decryptUrl(ciperText));

//assign permission set to FI on user creation
FinInstAccountService.assignCommunityPermissionSetAsync('005N000000ALmCFIA1');

system.debug(
  'ciperText : ' +
  FileService.getInstance()
    .fetchContentVersionByIdWithoutBlob('068N0000002BDJzIAO')
);

//
String str = 'zDtI623A6iJguO43gALe9aP1SUcRzC1S6P%2BCH3w8wwjHQn7t9AgYF%2F%2FRwxBWMbfWy%2BiignOSIKhKJ2c9sRVm1nVT6jXzIiOhQ7763UgngQ0z60e6WX7dLY6AeKZu%2F54RjMvD1clvKMPcm1rKhbOBH4omCfgVcF6QyNQmpl%2FXfJ4%3D';
Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(
  SecurityUtils.decryptUrl(str)
);
system.debug(Json.serialize(mp));


// 
String str='lTlmvHxNiXZSBgCGqoLKvODsJ1v5pSMQbIImIhIi8dVTpQm3OWqbN1j/ZJB4s99btOCcl0+lGLgFQzWB6Num5g==';
AuthenticationService.ApplicationContextDTO dto= (AuthenticationService.ApplicationContextDTO) JSON.deserialize(
  SecurityUtils.decryptBase64(str) , AuthenticationService.ApplicationContextDTO.class
);
system.debug(dto.edt.day());

