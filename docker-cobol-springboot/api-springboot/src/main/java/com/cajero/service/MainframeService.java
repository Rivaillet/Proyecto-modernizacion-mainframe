package com.cajero.service;

import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

@Service 
public class MainframeService {

    private final String HOST = "mydb2_moderno";
    private final int PORT = 9000;

    
    public String enviarTrama(String trama200Bytes) throws Exception {
        System.out.println("🔌 [SERVICE] Abriendo socket con el Core Mainframe...");
        
        try (Socket socket = new Socket(HOST, PORT);
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {
            
            // Enviamos
            out.print(trama200Bytes + "\n");
            out.flush();
            
            // Leemos respuesta
            System.out.println("⏳ [SERVICE] Trama enviada. Esperando respuesta...");
            return in.readLine(); 
            
        } 
    }
}