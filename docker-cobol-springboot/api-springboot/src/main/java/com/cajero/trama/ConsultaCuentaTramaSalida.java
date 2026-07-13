package com.cajero.trama;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public record ConsultaCuentaTramaSalida(
    String cdRetorno,
    int numCuentas,
    List<CuentaSaldos> listaCuentas
) {
    // El sub-record vive aquí dentro mágicamente
    public record CuentaSaldos(
        String iban,
        BigDecimal saldoEfectivo,
        BigDecimal saldoEmbargado
    ) {}

    // Constantes de diseño de la trama COBOL
    private static final int LONGITUD_TRAMA_ESPERADA = 524;
    private static final int TOTAL_OCURRENCIAS = 10;
    private static final int TAMANIO_ELEMENTO_CUENTA = 52;

    public static ConsultaCuentaTramaSalida desdeTramaRaw(String tramaRaw) {
        if (tramaRaw == null || tramaRaw.length() < LONGITUD_TRAMA_ESPERADA) {
            throw new IllegalArgumentException(
                "La trama recibida es inválida o incompleta. Se esperaban " 
                + LONGITUD_TRAMA_ESPERADA + " caracteres."
            );
        }

        // 1. Extraer cabecera fija
        String cdRetorno = tramaRaw.substring(0, 2);
        int numCuentas = Integer.parseInt(tramaRaw.substring(2, 4).trim());
        
        List<CuentaSaldos> cuentas = new ArrayList<>();
        int offset = 4; // El OCCURS empieza en el byte 4 (índice base 0)

        // 2. Procesar el OCCURS 10 TIMES
        for (int i = 0; i < TOTAL_OCURRENCIAS; i++) {
            // Extraemos los bloques de texto según el PIC de COBOL
            String iban = tramaRaw.substring(offset, offset + 24).trim();
            String rawSaldoEfectivo = tramaRaw.substring(offset + 24, offset + 38).trim();
            String rawSaldoEmbargado = tramaRaw.substring(offset + 38, offset + 52).trim();

            // Control de posiciones vacías: Si el IBAN está vacío, es que el Mainframe 
            // no ha llenado esta ocurrencia del array
            if (!iban.isEmpty()) {
                BigDecimal saldoEfectivo = new BigDecimal(rawSaldoEfectivo);
                BigDecimal saldoEmbargado = new BigDecimal(rawSaldoEmbargado);
                
                cuentas.add(new CuentaSaldos(iban, saldoEfectivo, saldoEmbargado));
            }

            // Desplazamos el puntero 52 bytes para leer la siguiente cuenta
            offset += TAMANIO_ELEMENTO_CUENTA;
        }

        return new ConsultaCuentaTramaSalida(cdRetorno, numCuentas, cuentas);
    }
}