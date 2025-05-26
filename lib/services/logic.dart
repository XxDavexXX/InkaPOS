class Logic {
	static String turnPriceToWords(double price) {
    final entero = price.floor();
    final decimal = ((price - entero) * 100).round();
    final enteroEnPalabras = _convertirNumero(entero);
    final decimalEnPalabras = decimal.toString().padLeft(2, '0');
    return 'Son $enteroEnPalabras CON $decimalEnPalabras/100 SOLES';
  }
  static String _convertirNumero(int numero) {
    if (numero == 0) {
      return 'CERO';
    }
    final unidades = [
      '',
      'UNO',
      'DOS',
      'TRES',
      'CUATRO',
      'CINCO',
      'SEIS',
      'SIETE',
      'OCHO',
      'NUEVE'
    ];
    final decenasEspeciales = [
      'DIEZ',
      'ONCE',
      'DOCE',
      'TRECE',
      'CATORCE',
      'QUINCE',
      'DIECISÉIS',
      'DIECISIETE',
      'DIECIOCHO',
      'DIECINUEVE'
    ];
    final decenas = [
      '',
      '',
      'VEINTE',
      'TREINTA',
      'CUARENTA',
      'CINCUENTA',
      'SESENTA',
      'SETENTA',
      'OCHENTA',
      'NOVENTA'
    ];
    final centenas = [
      '',
      'CIENTO',
      'DOSCIENTOS',
      'TRESCIENTOS',
      'CUATROCIENTOS',
      'QUINIENTOS',
      'SEISCIENTOS',
      'SETECIENTOS',
      'OCHOCIENTOS',
      'NOVECIENTOS'
    ];
    final miles = ['', 'MIL', 'MILLÓN', 'MIL MILLONES', 'BILLÓN', 'MIL BILLONES'];

    String resultado = '';
    int grupo = 0;

    while (numero > 0) {
      final grupoNumero = numero % 1000;
      if (grupoNumero != 0) {
        String grupoEnPalabras = '';
        final centena = (grupoNumero ~/ 100);
        final decenaUnidad = grupoNumero % 100;

        if (centena > 0) {
          grupoEnPalabras += centenas[centena];
        }

        if (decenaUnidad > 0) {
          if (grupoEnPalabras.isNotEmpty) {
            grupoEnPalabras += ' ';
          }
          if (decenaUnidad < 10) {
            grupoEnPalabras += unidades[decenaUnidad];
          } else if (decenaUnidad >= 10 && decenaUnidad <= 19) {
            grupoEnPalabras += decenasEspeciales[decenaUnidad - 10];
          } else {
            final decena = decenaUnidad ~/ 10;
            final unidad = decenaUnidad % 10;
            grupoEnPalabras += decenas[decena];
            if (unidad > 0) {
              grupoEnPalabras += ' Y ' + unidades[unidad];
            }
          }
        }

        if (grupo > 0) {
          if (resultado.isNotEmpty) {
            if (grupo == 2 && grupoNumero == 1) {
              resultado = miles[grupo] + ' ' + resultado;
            } else {
              resultado = miles[grupo] + ' ' + resultado;
            }
          } else {
            if (grupo == 2 && grupoNumero == 1) {
              resultado = miles[grupo];
            } else {
              resultado = grupoEnPalabras + ' ' + miles[grupo];
            }
          }
        } else {
          resultado = grupoEnPalabras;
        }
      }
      numero ~/= 1000;
      grupo++;
    }

    return resultado;
  }
}