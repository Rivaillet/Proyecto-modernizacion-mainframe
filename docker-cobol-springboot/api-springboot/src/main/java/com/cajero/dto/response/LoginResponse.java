package com.cajero.dto.response;

public class LoginResponse {
    private String status;
    private String message;

    // Constructor vacío obligatorio para que las librerías de JSON puedan mapearlo
    public LoginResponse() {
    }

    // Constructor con parámetros que usamos en el Controller
    public LoginResponse(String status, String message) {
        this.status = status;
        this.message = message;
    }

    // Getters y Setters
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
