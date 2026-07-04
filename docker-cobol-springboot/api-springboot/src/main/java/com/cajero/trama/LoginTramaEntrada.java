package com.cajero.trama;

public class LoginTramaEntrada {
    private static final int LONGITUD_OPCODE = 4;   
    private static final int LONGITUD_DNI = 9;    
    private static final int LONGITUD_PASSWORD = 20;
    private static final int LONGITUD_TOTAL = 200; 


    public static String buildPeticion(String dni, String password) {
        String opCode = "LOGI";

        String campos = String.format("%-" + LONGITUD_OPCODE + "s" +
                                      "%-" + LONGITUD_DNI + "s" +
                                      "%-" + LONGITUD_PASSWORD + "s", 
                                      opCode, dni, password);

        
        return String.format("%-" + LONGITUD_TOTAL + "s", campos);
    }

  
    public static boolean parseRespuesta(String respuestaCruda) {
        if (respuestaCruda == null || respuestaCruda.trim().isEmpty()) {
            return false;
        }
        
        return respuestaCruda.contains("00");
    }
}
