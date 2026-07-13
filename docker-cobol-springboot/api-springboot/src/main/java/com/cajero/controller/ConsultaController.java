package com.cajero.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cajero.dto.response.ConsultaCuentaResponse;
import com.cajero.service.MainframeService;
import com.cajero.trama.ConsultaCuentaTramaEntrada;
import com.cajero.trama.ConsultaCuentaTramaSalida;

@RestController
@RequestMapping("api/consulta")
public class ConsultaController {
    
    private final MainframeService mainframeService;

    public ConsultaController(MainframeService mainframeService){
        this.mainframeService = mainframeService;
    }

    @GetMapping("/cuenta/{idCliente}")
    public ResponseEntity<?> obtenerCuentasCliente(@PathVariable String idCliente){
        
        System.out.println("\n📥 [Spring Boot] Petición recibida para ID Cliente: " + idCliente);
        
        String tramaEntrada = ConsultaCuentaTramaEntrada.buildPeticion(idCliente);
        System.out.println("📡 [Spring Boot] Trama de entrada enviada al puente: [" + tramaEntrada + "]");
        
        try {
            String respuestaCruda = mainframeService.enviarTrama(tramaEntrada);
            System.out.println("🛰️ [Mainframe] Respuesta cruda (Buffer bytes/texto): [" + respuestaCruda + "]");
            
            // 1. Procesamos y parseamos el churro de bytes de COBOL
            ConsultaCuentaTramaSalida tramaSalida = ConsultaCuentaTramaSalida.desdeTramaRaw(respuestaCruda);
            
            // 2. Mapeamos los datos técnicos de la trama al DTO de salida de la API
            // (Evitamos exponer la lógica cruda del Mainframe directamente al frontend)
            ConsultaCuentaResponse response = new ConsultaCuentaResponse(
                tramaSalida.cdRetorno(),
                tramaSalida.numCuentas(),
                tramaSalida.listaCuentas()
            );
            
            // 3. Spring Boot convertirá automáticamente este objeto a un JSON limpio
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.out.println("❌ [Error Mainframe]: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al conectar con el Core: " + e.getMessage());
        }
    }
}