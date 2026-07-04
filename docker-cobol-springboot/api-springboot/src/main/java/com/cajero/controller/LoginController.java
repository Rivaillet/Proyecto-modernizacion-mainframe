package com.cajero.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cajero.dto.request.LoginRequestDTO;
import com.cajero.dto.response.LoginResponse;
import com.cajero.service.MainframeService;
import com.cajero.trama.LoginTramaEntrada;
import com.cajero.trama.LoginTramaSalida;

@RestController
@RequestMapping("/api/auth")
public class LoginController {

    private final MainframeService mainframeService;

    public LoginController(MainframeService mainframeService) {
        this.mainframeService = mainframeService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> comprobarCredenciales(@RequestBody LoginRequestDTO loginRequest) {

        try {
         
            String tramaEnvio = LoginTramaEntrada.buildPeticion(loginRequest.getDni(), loginRequest.getPassword());

         
            String respuestaCruda = mainframeService.enviarTrama(tramaEnvio);

       
            LoginTramaSalida tramaSalida = new LoginTramaSalida(respuestaCruda);

         
            if (tramaSalida.isSuccess()) {
                return ResponseEntity.ok(new LoginResponse("OK", "Bienvenido " + tramaSalida.getNombreCliente()));
            } else if ("01".equals(tramaSalida.getCodigoRetorno())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new LoginResponse("ERROR", "El DNI no existe"));
            } else if ("02".equals(tramaSalida.getCodigoRetorno())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(new LoginResponse("ERROR", "Contraseña incorrecta"));
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(new LoginResponse("DOWN", "Error crítico en Core"));
            }

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new LoginResponse("DOWN", e.getMessage()));
        }

    }
}