import 'package:control_inv/services/storage_app.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Renovation {
  
StorageApp sm = StorageApp();

Future<bool> jwt () async {

  await sm.initialize();
  String token =  sm.getSession() ?? '';
  bool isTokenExpired = true;

  if (token == '') {
    isTokenExpired = true;
  } else {
  /* decode() method will decode your token's payload */
   Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  // Now you can use your decoded token
  // print(decodedToken["name"]);

  /* isExpired() - you can use this method to know if your token is already expired or not.
  An useful method when you have to handle sessions and you want the user
  to authenticate if has an expired token */
  // bool isTokenExpired = JwtDecoder.isExpired(token);
  int dateActual = DateTime.now().millisecondsSinceEpoch;

  if (int.parse(decodedToken["exp"].toString()) < dateActual) { 
    isTokenExpired = true;
    // The user should authenticate
  }else{
    isTokenExpired = false;
  }

  isTokenExpired = false;

  /* getExpirationDate() - this method returns the expiration date of the token */
  // DateTime expirationDate = JwtDecoder.getExpirationDate(token);

  // 2025-01-13 13:04:18.000
  // print(expirationDate);

  /* getTokenTime() - You can use this method to know how old your token is */
  // Duration tokenTime = JwtDecoder.getTokenTime(token);

  // 15
  // print(tokenTime.inHours);

  }
  
  return isTokenExpired;
}

}