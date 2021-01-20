pragma solidity ^0.5.0;

import "./Pregrado.sol";

contract PregradoCertificados is Pregrado {
 
  //Para mostrar todos los egresos de la persona (Si tiene más de una carrera/postgrado)
  function mostrarEgresosPersona(uint cedula)
    public view
    returns(uint[] memory)
  {
    /*require(existenciaEgresado(cedula), "La persona no posee egresos");*/
    return mapeoEgresoPersona[cedula].idToken;
  }

  //Descripción del egreso según el idToken
  function describirEgreso(uint idToken)
    public view
    returns(uint, uint, bool, bool)
  {
    return (mapeoEstructuraEgreso[idToken].mencion,
            mapeoEstructuraEgreso[idToken].year,
            mapeoEstructuraEgreso[idToken].egresado,
            mapeoEstructuraEgreso[idToken].revocado);
  }

  function mostrarCertificadosPorConfirmar()
    public view
    returns(uint[] memory)
  {
    return _tokensOfOwner(msg.sender);
  }

}
