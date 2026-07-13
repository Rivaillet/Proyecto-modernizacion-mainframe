package com.cajero.dto.response;

import java.util.List;
import com.cajero.trama.ConsultaCuentaTramaSalida.CuentaSaldos;

public record ConsultaCuentaResponse(
    String codigoRetorno,
    int totalCuentas,
    List<CuentaSaldos> cuentas
) {}