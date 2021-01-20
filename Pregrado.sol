pragma solidity ^0.5.0;


import "./Carrera.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol";

contract Pregrado is Carrera, ERC721Enumerable {

  struct estructuraEgresoPersona {
    uint[] idToken;
  }
  //La clave será la cedula del egresado y dirigirá a los tokens que posee la persona
  mapping(uint => estructuraEgresoPersona) internal mapeoEgresoPersona;
  
  struct estructuraEgreso {
    uint mencion;
    uint year;
    bool egresado;
    bool revocado;
  }
  //La clave será el idToken y dirigirá a la descripción de la carrera
  mapping(uint => estructuraEgreso) internal mapeoEstructuraEgreso;

  //Arreglo de cédulas cuyo indice son los tokens/carreras creados
  uint[] internal arregloCedulaSegunToken;

  event egresoCreado(address indexed creador, uint indexed cedula, uint indexed idToken, uint mencion, uint year, uint fechaHora);
  event egresoEditado(address indexed editor, uint indexed idToken, uint mencionAnterior, uint mencion, uint year, uint fechaHora);
  //event egresoTransferido(uint fechaHora);
  event certificadoActividad(bytes2 actividad, address indexed revocador, uint indexed idToken, bytes32 razon, uint fechaHora);

  function mostrarCedulaSegunToken(uint idToken)
    public view
    returns(uint)
  {
    return arregloCedulaSegunToken[idToken];
  }

  function egresoComprobado(uint cedula, uint mencion)
    public view
    returns(bool)
  {
    uint longitud = mapeoEgresoPersona[cedula].idToken.length;
    uint token;
    for (uint i = 0; i < longitud; i++)
    {
      token = mapeoEgresoPersona[cedula].idToken[i];
      if (mapeoEstructuraEgreso[token].mencion == mencion)
        return true;
    }
  }

  function generarEgreso(uint cedula, uint mencion, uint year)
    public
  {
    require(msg.sender == arregloCertificadores[0], "Sin autorización");
    require(!egresoComprobado(cedula, mencion), "Ya egresado");
    require(comprobarMencion(mencion), "Mencion no existe");
    uint idToken = totalSupply();
    _mint(arregloCertificadores[0], idToken);
    mapeoEstructuraEgreso[idToken].mencion = mencion;
    mapeoEstructuraEgreso[idToken].year = year;
    mapeoEstructuraEgreso[idToken].egresado = false;
    mapeoEstructuraEgreso[idToken].revocado = false;
    mapeoEgresoPersona[cedula].idToken.push(idToken);
    arregloCedulaSegunToken.push(cedula);
    emit egresoCreado(msg.sender, cedula, idToken, mencion, year, now);
  }

  function generarEgresos(uint[] memory cedulas, uint mencion, uint year)
    public
  {
    for (uint i = 0; i < cedulas.length; i++)
    {
      generarEgreso(cedulas[i], mencion, year);
    }
  }

  function editarEgresado(uint idToken, uint mencion, uint year)
    public
  {
    require(msg.sender == arregloCertificadores[0], "Sin autorización");
    require(_exists(idToken),"Egresado no existe");
    require(comprobarMencion(mencion), "Mencion no existe");
    uint mencionAnterior = mapeoEstructuraEgreso[idToken].mencion;
    mapeoEstructuraEgreso[idToken].mencion = mencion;
    mapeoEstructuraEgreso[idToken].year = year;
    emit egresoEditado(msg.sender, idToken, mencionAnterior, mencion, year, now);
  }

  function transferirEgresado(uint idToken)
    public esCertificador
  {
    require(_exists(idToken), "Egresado no existe");
    address apunta = mapeoCertificadores[msg.sender].apunta;
    transferFrom(msg.sender, apunta, idToken);
    if (apunta == administrador)
      mapeoEstructuraEgreso[idToken].egresado = true;
    //emit egresoTransferido(now);
  }

  function revocarCertificado(uint idToken, bytes32 razon)
    public esCertificador
  {
    mapeoEstructuraEgreso[idToken].revocado = true;
    emit certificadoActividad("I", msg.sender, idToken, razon, now);
  }

  function reactivarCertificado(uint idToken, bytes32 razon)
    public esCertificador
  {
    mapeoEstructuraEgreso[idToken].revocado = false;
    emit certificadoActividad("A", msg.sender, idToken, razon, now);
  }
}