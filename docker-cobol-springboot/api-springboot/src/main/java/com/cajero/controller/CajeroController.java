package com.cajero.controller;

import com.cajero.service.CobolBridgeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CajeroController {

    private final CobolBridgeService cobolService;

    public CajeroController(CobolBridgeService cobolService) {
        this.cobolService = cobolService;
    }

    @GetMapping("/consultar")
    public String consultarMainframe(@RequestParam String cuenta) {
        return cobolService.enviarDatoACobol(cuenta);
    }
}