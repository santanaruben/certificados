pragma solidity ^0.5.0;

import "./Certificador.sol";

contract Carrera is Certificador {

  event LogCarrera(bytes2 actividad, uint indexed carrera, bytes32 nombreCarrera, address indexed certificador, uint tipo, uint fechaHora);
  event LogCarreraModificada(uint indexed carrera, bytes32 nombreAnterior, bytes32 nombreCarrera, address indexed certificador, uint fechaHora);
  event LogMencionCreada(uint indexed carrera, bytes32 nombreCarrera, uint indexed mencion, bytes32 nombreMencion, uint imagenMencion, address indexed certificador, uint fechaHora);
  event LogMencionModificada(uint indexed mencion, bytes32 nombreMencionAnterior, bytes32 nombreMencion, address indexed certificador, uint fechaHora);
  event LogMencionActividad(bytes2 actividad, uint indexed mencion, bytes32 nombreMencion, address indexed certificador, uint fechaHora);
  
  struct estructuraCarrera {
    bytes32 nombreCarrera;
    uint tipo;
    uint[] arregloMencion;
  }

  struct estructuraMencion {
    uint imagenMencion;
    uint carreraPadre; //Atributo para encontrar la carrera que la contiene
  }

  mapping(uint => estructuraMencion) private mapeoMencion;

  mapping(uint => estructuraCarrera) private mapeoCarrera;
  uint[] private arregloCarrera;
  bytes32[] internal arregloNombreMencion;

  //Arreglo que almacena un booleano indicando si la mención existe
  bool[] private arregloActividadMencion;
  
  function agregarCarrera(
              bytes32 nombreCarrera,
              uint tipo)
    public esCertificador
  {
    uint carrera = arregloCarrera.length;
    arregloCarrera.push(carrera);
    mapeoCarrera[carrera].nombreCarrera = nombreCarrera;
    mapeoCarrera[carrera].tipo = tipo;
    emit LogCarrera("C", carrera, nombreCarrera, msg.sender, tipo, now);
  }

  function mostrarCarreras()
    public view
    returns(uint[] memory)
  {
    return arregloCarrera;
  }

  function describirCarrera(uint carrera)
    public view
    returns(bytes32, uint)
  {
    return (mapeoCarrera[carrera].nombreCarrera,
            mapeoCarrera[carrera].tipo);
  }

  function modificarCarrera(uint carrera, bytes32 nombreCarrera)
    public esCertificador
  {
    require(existenciaCarrera(carrera), "Carrera no existe");
    bytes32 nombreAnterior = mapeoCarrera[carrera].nombreCarrera;
    mapeoCarrera[carrera].nombreCarrera = nombreCarrera;
    emit LogCarreraModificada(carrera, nombreAnterior, nombreCarrera, msg.sender, now);
  }

  function modificarTipoCarrera(uint carrera, uint tipo)
    public esCertificador
  {
    require(existenciaCarrera(carrera), "Carrera no existe");
    mapeoCarrera[carrera].tipo = tipo;
  }

  function eliminarUltimaCarrera()
    public esCertificador
  {
    require(arregloCarrera.length > 0, "Sin carreras");
    uint carreraIdEliminada = arregloCarrera.length-1;
    require(!existenciaDeMenciones(carreraIdEliminada), "Tiene menciones.");
    bytes32 nombreCarreraIdEliminada = mapeoCarrera[carreraIdEliminada].nombreCarrera;
    uint tipo = mapeoCarrera[carreraIdEliminada].tipo;
    arregloCarrera.length--;
    emit LogCarrera("E", carreraIdEliminada, nombreCarreraIdEliminada, msg.sender, tipo, now);
  }

  function existenciaCarrera(uint carrera)
    public view
    returns (bool)
  {
    if (carrera <= arregloCarrera.length-1)
      return true;
  }

  function agregarMencion(
              uint carrera,
              bytes32 nombreMencion,
              uint imagenMencion)
    public esCertificador
  {
    require(existenciaCarrera(carrera), "Carrera no existe");
    uint mencionValor = arregloNombreMencion.length;
    mapeoCarrera[carrera].arregloMencion.push(mencionValor);
    arregloNombreMencion.push(nombreMencion);
    arregloActividadMencion.push(true);
    mapeoMencion[mencionValor].imagenMencion = imagenMencion;
    mapeoMencion[mencionValor].carreraPadre = carrera;
    (bytes32 nombreCarrera,) = describirCarrera(carrera);
    emit LogMencionCreada(carrera, nombreCarrera, mencionValor, nombreMencion, imagenMencion, msg.sender, now);
  }

  function existenciaDeMenciones(uint carrera)
    public view
    returns (bool)
  {
    if (mapeoCarrera[carrera].arregloMencion.length > 0)
      return true;
  }

  function mostrarMenciones(uint carrera)
    public view
    returns(uint[] memory)
  {
    //require(existenciaDeMenciones(carrera), "Sin menciones");
    return mapeoCarrera[carrera].arregloMencion;
  }

  function actividadMencion(uint mencion)
    public view
    returns (bool)
  {
    if (arregloActividadMencion[mencion] == true)
      return true;
  }

  function describirMencion(uint mencion)
    public view
    returns(bytes32, uint, uint)
  {
    
    return (arregloNombreMencion[mencion],
            mapeoMencion[mencion].imagenMencion,
            mapeoMencion[mencion].carreraPadre);
  }

  function modificarMencion(uint mencion, bytes32 nombreMencion)
    public esCertificador
  {
    require(comprobarMencion(mencion), "Mencion no existe");
    bytes32 nombreMencionAnterior = arregloNombreMencion[mencion];
    arregloNombreMencion[mencion] = nombreMencion;
    emit LogMencionModificada(mencion, nombreMencionAnterior, nombreMencion, msg.sender, now);
  }

  function modificarImagenMencion(uint mencion, uint imagenMencion)
    public esCertificador
  {
    require(comprobarMencion(mencion), "Mencion no existe");
    mapeoMencion[mencion].imagenMencion = imagenMencion;
  }

  function desactivarMencion(uint mencion)
    public esCertificador
  {
    require(actividadMencion(mencion), "Ya desactivada");
    bytes32 nombreMencionDesactivada = arregloNombreMencion[mencion];
    arregloActividadMencion[mencion] = false;
    emit LogMencionActividad("D", mencion, nombreMencionDesactivada, msg.sender, now);
  }

  function activarMencion(uint mencion)
    public esCertificador
  {
    require(!actividadMencion(mencion), "Ya activada");
    bytes32 nombreMencionActivada = arregloNombreMencion[mencion];
    arregloActividadMencion[mencion] = true;
    emit LogMencionActividad("A", mencion, nombreMencionActivada, msg.sender, now);
  }

  function comprobarMencion(uint mencion)
    public view
    returns(bool)
  {
    if (arregloNombreMencion.length-1 >= mencion)
      return true;
  }
}