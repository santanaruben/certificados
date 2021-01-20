pragma solidity ^0.5.0;

import "./Cursos.sol";

contract CursosPersona is Cursos {

  event LogCursoPersonaAgregada(uint indexed cedula, uint indexed identificadorCurso, address indexed certificador, uint fechaHora);
  event LogCursoPersonaEliminada(uint indexed cedula, uint indexed identificadorCurso, address indexed certificador, uint fechaHora);

  struct estructuraCursosPersona {
    uint[] arregloIdentificadorCurso;
  }

  //La clave del arreglo y el mapeo será el tokenId el cual es la cedula del egresado
  mapping(uint => estructuraCursosPersona) private mapeoCursosPersona;

  function mostrarCursosPersona(uint cedula)
    public view
    returns(uint[] memory)
  {
    return mapeoCursosPersona[cedula].arregloIdentificadorCurso;
  }

  function existenciaCursoPersona(uint cedula)
    public view
    returns (bool existencia)
  {
    if (mapeoCursosPersona[cedula].arregloIdentificadorCurso.length > 0)
      return true;
  }

  function yaCertificado(uint cedula, uint curso)
    public view
    returns (bool existencia)
  {
    require(existenciaCurso(curso), "Curso no existe");
    uint[] memory cursos =  mostrarCursosPersona(cedula);
    for (uint i = 0; i < cursos.length; i++)
    {
      if(cursos[i] == curso)
        return true;
    }
  }

  function agregarCursoPersonas(
              uint[] memory cedulas,
              uint identificadorCurso)
    public
    returns (bool exito)
  {
    require(msg.sender == autorizadoCurso(identificadorCurso), "Usted no está autorizado para realizar funciones sobre este curso");
    for (uint i = 0; i < cedulas.length; i++)
    {
      agregarCursoPersona(cedulas[i], identificadorCurso);
    }
    return true;
  }

  function agregarCursoPersona(
              uint cedula,
              uint identificadorCurso)
    public
    returns (bool exito)
  {
    require(msg.sender == autorizadoCurso(identificadorCurso), "Usted no está autorizado para realizar funciones sobre este curso");
    require(!(yaCertificado(cedula, identificadorCurso)),"Ya certificado");
    mapeoCursosPersona[cedula].arregloIdentificadorCurso.push(identificadorCurso);
    emit LogCursoPersonaAgregada(cedula, identificadorCurso, msg.sender, now);
    return true;
  }

  function eliminarCursoPersona(
              uint cedula,
              uint identificadorCurso)
    public
    returns (bool exito)
  {
    require(msg.sender == autorizadoCurso(identificadorCurso), "Usted no está autorizado para realizar funciones sobre este curso");
    require(existenciaCursoPersona(cedula), "La persona no tiene cursos");
    require(existenciaCurso(identificadorCurso), "Curso no existe o es inválido");
    uint tamano = mapeoCursosPersona[cedula].arregloIdentificadorCurso.length;
    bool encontrado = false;
    for(uint i = 0; i < tamano; i++) {
      if(mapeoCursosPersona[cedula].arregloIdentificadorCurso[i] == identificadorCurso)
      {
        encontrado = true;
        mapeoCursosPersona[cedula].arregloIdentificadorCurso[i] = mapeoCursosPersona[cedula].arregloIdentificadorCurso[mapeoCursosPersona[cedula].arregloIdentificadorCurso.length - 1];
        mapeoCursosPersona[cedula].arregloIdentificadorCurso.length--;
        emit LogCursoPersonaEliminada(cedula, identificadorCurso, msg.sender, now);
        return true;
      }
    }
    if(encontrado == false) return false;
  }
}