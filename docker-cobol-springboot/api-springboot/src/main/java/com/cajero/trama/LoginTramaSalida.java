package com.cajero.trama;

public class LoginTramaSalida {
    
    private final String codigoRetorno; 
    private final String nombreCliente;  
    private final String idCliente;

    
    public LoginTramaSalida(String respuestaCruda) {
        if (respuestaCruda == null || respuestaCruda.length() < 111) {
            this.codigoRetorno = "99"; 
            this.nombreCliente = "";
            this.idCliente     = "0000000000";
            return;
        }
        
        this.codigoRetorno = respuestaCruda.substring(0, 2).trim();
        this.idCliente     = respuestaCruda.substring(2,11).trim();
        this.nombreCliente = respuestaCruda.substring(11, 111).trim();
    }

    public boolean isSuccess() {
        return "00".equals(this.codigoRetorno);
    }

    public String getCodigoRetorno() { return codigoRetorno; }
    public String getNombreCliente() { return nombreCliente; }
    public String getIdCliente()     { return idCliente; }
}
