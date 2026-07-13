package com.cajero.trama;

public class ConsultaCuentaTramaEntrada {
    
    private static final int LONGITUD_OPCODE = 4;   
    private static final int LONGITUD_ID_CLIENTE = 9;  
     private static final int LONGITUD_TOTAL = 200;   


    public static String buildPeticion(String idCliente) {
        String opCode = "CONS";
        long idNumerico = Long.parseLong(idCliente.trim());

        String campos = String.format("%-" + LONGITUD_OPCODE + "s" +
                                      "%0" + LONGITUD_ID_CLIENTE + "d",     
                                      opCode,idNumerico);

        
        return String.format("%-" + LONGITUD_TOTAL + "s", campos);
    }

  
    public static boolean parseRespuesta(String respuestaCruda) {
        if (respuestaCruda == null || respuestaCruda.trim().isEmpty()) {
            return false;
        }
        
        return respuestaCruda.contains("00");
    }
}
