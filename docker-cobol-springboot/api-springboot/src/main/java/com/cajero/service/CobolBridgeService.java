package com.cajero.service;

import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

@Service
public class CobolBridgeService {
    private final String COBOL_HOST = "mydb2_moderno";
    private final int COBOL_PORT = 9000;

    public String enviarDatoACobol(String datoEnviar) {
        StringBuilder resultadoCobol = new StringBuilder();
        try (Socket socket = new Socket(COBOL_HOST, COBOL_PORT);
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

            out.println(datoEnviar);

            String linea;
            while ((linea = in.readLine()) != null) {
                resultadoCobol.append(linea).append("\n");
            }
        } catch (Exception e) {
            return "Error de conexión con el Mainframe simulado: " + e.getMessage();
        }
        return resultadoCobol.toString().trim();
    }
}