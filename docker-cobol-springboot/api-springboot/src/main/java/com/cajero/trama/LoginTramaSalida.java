package com.cajero.trama;

public class LoginTramaSalida {
    
    private final String codigoRetorno; 
    private final String nombreCliente;  

    // El constructor procesa la trama posicional pura
    public LoginTramaSalida(String respuestaCruda) {
        if (respuestaCruda == null || respuestaCruda.length() < 102) {
            this.codigoRetorno = "99"; 
            this.nombreCliente = "";
            return;
        }
        
        this.codigoRetorno = respuestaCruda.substring(0, 2).trim();
        this.nombreCliente = respuestaCruda.substring(2, 102).trim();
    }

    public boolean isSuccess() {
        return "00".equals(this.codigoRetorno);
    }

    public String getCodigoRetorno() { return codigoRetorno; }
    public String getNombreCliente() { return nombreCliente; }
}
