package main.java.com.cajero;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class MainframeQuickTest {

    public static void main(String[] args) {
        String host = "localhost";
        int port = 9000;

        String opCode = "LOGI";
        String dni = "12345678A";
        String password = "Pass1234";

        System.out.println("=== [TEST] Iniciando verificación rápida con el COBOL ===");

        String datos = String.format("%-4s%-9s%-20s", opCode, dni, password);
        String trama200Bytes = String.format("%-200s", datos);

        try (Socket socket = new Socket(host, port);
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

            System.out.println("[+] Conectado a Netcat en el puerto " + port);
            System.out.println("[+] Enviando trama...");
            
            out.print(trama200Bytes + "\n");
            out.flush();

            System.out.println("[+] Esperando respuesta...");
            String respuesta = in.readLine();

            System.out.println("\n==============================================");
            System.out.println(" RESPUESTA CRUDA: [" + respuesta + "]");
            System.out.println("==============================================");
            
            if (respuesta != null) {
                System.out.println(" 🟢 ¡ÉXITO! Conexión y validación correctas.");
            } else {
                System.out.println(" 🔴 ¡ALERTA! No se recibió el OK esperado.");
            }

        } catch (Exception e) {
            System.out.println("\n==============================================");
            System.out.println(" ❌ ERROR DE CONEXIÓN: " + e.getMessage());
            System.out.println("==============================================");
        }
    }
}