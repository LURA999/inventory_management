import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentService {
   Future<void> submitPayment(String cardNumber, String expiryMonth, String expiryYear,
   String cvv, String cardHolderName, int amountMonth, GlobalKey<FormState> formKey, BuildContext context)  
    async {
      
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Envía los datos al backend
      final response = await http.post(
        Uri.parse('https://tuservidor.com/api/payments'),
        headers: {'Content-Type': 'application/json'},
        body: '''{
          "cardNumber": "$cardNumber",
          "expiryMonth": "$expiryMonth",
          "expiryYear": "$expiryYear",
          "cvv": "$cvv",
          "cardHolderName": "$cardHolderName",
          "amount": "100.00",
          "currency": "MXN"
        }''',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago realizado con éxito'), backgroundColor: Colors.green,));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el pago: ${response.body}'), backgroundColor: Colors.red));
      }
    }
  }
 }
 
 