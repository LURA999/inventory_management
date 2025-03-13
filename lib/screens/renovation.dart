
import 'package:control_inv/services/payment_service.dart';
import 'package:control_inv/services/storage_app.dart';
import 'package:control_inv/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_braintree/flutter_braintree.dart';

class RenovationScreen extends StatefulWidget {
  const RenovationScreen({super.key});

  @override
  State<RenovationScreen> createState() => _RenovationScreenState();
}

class _RenovationScreenState extends State<RenovationScreen> {
  List<ConnectivityResult>?  _connectivityResult;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    PaymentService svPay = PaymentService();
    String cardNumber = '';
    String expiryMonth = '';
    String expiryYear = '';
    String cvv = '';
    String cardHolderName = '';
    int amountMonth = 0; 

    @override
  void initState() {
    _checkConnectivity();
    super.initState();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _connectivityResult = connectivityResult;
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Renovación"),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left:20, right: 20, top: 20, bottom: 10),
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, right: MediaQuery.of(context).size.width * 0.1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Para pagar por un mes o más del servicio, tendra las siguientes opciones:',
                            style: TextStyle(color: Colors.black, 
                            fontFamily: 'Open Sans', decoration: TextDecoration.none,
                            fontSize: 18), textAlign: TextAlign.left,
                          ),
                          SizedBox(height:  10,),
                          _connectivityResult != null  && _connectivityResult!.isNotEmpty ?
                          // Text('Conexion ${_connectivityResult}')
                            showOptions(_connectivityResult!)
                          :
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    SizedBox(height:  10,),
                    ElevatedButton(onPressed:  () async {
                      if (!(await Renovation().jwt())) {
                        Navigator.pushNamed(context,'/');
                      }else{
                       await _checkConnectivity();
                      } 
                    },child: Text('Recargar'),
                    )
                  ],
                ),
              ),
              SizedBox(height: 50,)
            ],
          ),
          )
        ),
      ),
    );
  }

  Widget showOptions(List<ConnectivityResult> con) {

    if (con[0] == ConnectivityResult.mobile || con[0] == ConnectivityResult.wifi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Por Invitado: ", style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 15,),
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Código...'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Introduce el código' : null,
              onSaved: (value) => expiryMonth = value!,
            ),
            ElevatedButton(onPressed: () {}, child: Text('Entrar'))
          ],
        ),
        SizedBox(height: 15,),
        Text("Por celular al número 6861448196 (300MXN por Mes): ", style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 15,),
        Column(
          children: [
            Text('El siguiente boton se activará cuando se realice el pago'),
            ElevatedButton(onPressed: () {}, child: Text('$amountMonth Meses'))
          ],
        ),
        SizedBox(height: 15,),
        Text("Con tarjeta de credito o debito (320MXN por Mes):", style: TextStyle(fontWeight: FontWeight.bold) ),
        //Segundo intento
      Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Número de Tarjeta'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Introduce el número de tarjeta' : null,
                onSaved: (value) => cardNumber = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mes de Expiración (MM)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Introduce el mes de expiración' : null,
                onSaved: (value) => expiryMonth = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Año de Expiración (YY)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Introduce el año de expiración' : null,
                onSaved: (value) => expiryYear = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Introduce el CVV' : null,
                onSaved: (value) => cvv = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del Titular'),
                validator: (value) => value!.isEmpty
                    ? 'Introduce el nombre del titular'
                    : null,
                onSaved: (value) => cardHolderName = value!,
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
              scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('1 Mes'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('3 Mes'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('6 Mes'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('1 Año'),
                  )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
               /*  await svPay.submitPayment(cardNumber, expiryMonth, expiryYear, cvv, 
                cardHolderName, amountMonth, _formKey, context); */
                  StorageApp sm = StorageApp();
                  sm.saveSession('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNzM3Njc0Nzk3LCJleHAiOjE3Mzg4ODQzOTd9._yAWLZ3RSL1bat7j_LMBgKRq-CI62te0K1mPTrfKDxg');
                } ,
                child: Text('Pagar'),
              ),
            ],
          ),
        )
                
      ],
    ); 
    } else {
      return Text( "Por favor, extableza una señal de internet");
    }
    
  }


  //segundo intento
/* 
    Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      // Aquí se genera el token del cliente desde tu servidor
      String clientToken = await _getClientToken();

      // Muestra el Drop-In UI
      var request = BraintreeDropInRequest(
        tokenizationKey: clientToken,
        collectDeviceData: true,
        paypalRequest: BraintreePayPalRequest(
          amount: amount.toStringAsFixed(2),
          currencyCode: 'MXN',
        ),
        cardEnabled: true,
      );

      BraintreeDropInResult? result =
          await BraintreeDropIn.start(request);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago exitoso. ID: ${result.paymentMethodNonce.nonce}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago cancelado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _getClientToken() async {
    // Implementa la llamada a tu servidor para obtener el Client Token
    // Ejemplo:
    return 'sandbox_f252zhq7_hh4cpc39zq4rgjcg';
  } */
}