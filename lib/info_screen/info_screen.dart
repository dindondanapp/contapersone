import 'package:flutter/material.dart';

/// A screen with basic information on this app
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informazioni'),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: Image.asset(
                    'assets/round_icon.png',
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                '''Contapersone è lo strumento semplice ed efficace per contare gli accessi a eventi, esercizi commerciali, celebrazioni religiose e tanto altro, anche i presenza di ingressi multipli.

Per iniziare crea un nuovo contapersone, specificando facoltativamente la capienza. Potrai poi condividere il conteggio con altri dispositivi, ad esempio per monitorare più ingressi contemporaneamente, tramite un semplice link o un codice QR. Avrai sempre sotto controllo il conteggio totale di tutti i dispositivi, sincronizzato in tempo reale.

Il servizio è gratuito per tutti, ma nasce in particolare per il monitoraggio degli accessi in chiesa. Se sei responsabile di una parrocchia puoi accedere all'"Area riservata parrocchie", per avere accesso alle statistiche di utilizzo e ad altri utili servizi sul portale web di DinDonDan!''',
                textAlign: TextAlign.justify,
              )
            ],
          ),
        ),
      ),
    );
  }
}
