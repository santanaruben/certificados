pragma solidity ^0.5.0;

import "./Usuario.sol";

contract Cursos is Usuario {

  event LogCursoCreado(address indexed creador, uint indexed identificadorCurso, bytes32 nombreCurso, uint categoriaCurso, uint subcategoriaCurso, uint duracion, address autorizado, uint fechaHora);
  event LogCursoEliminado(address indexed eliminador, uint indexed identificadorCurso, bytes32 nombreCurso, uint fechaHora);
  event LogCursoModificado(address indexed modificador, uint indexed identificadorCurso, bytes32 nombreCurso, uint categoriaCurso, uint subcategoriaCurso, uint duracion, address autorizado, uint fechaHora);
  event LogCategoriaCursoCreada(uint indexed categoriaCurso, bytes32 nombreCategoriaCurso, address indexed certificador, uint fechaHora);
  event LogCategoriaCursoModificada(uint indexed categoriaCurso, bytes32 nombreAnterior, bytes32 nombreCategoriaCurso, address indexed certificador, uint fechaHora);
  event LogCategoriaCursoEliminada(uint indexed categoriaCursoEliminada, bytes32 nombreCategoriaCursoEliminada, address indexed certificador, uint fechaHora);
  event LogSubcategoriaCursoCreada(uint indexed categoriaCurso, bytes32 nombreCategoriaCurso, uint indexed subcategoriaCurso, bytes32 nombreSubcategoriaCurso, uint imagenSubcategoria, address indexed certificador, uint fechaHora);
  event LogSubcategoriaCursoModificada(uint indexed subcategoriaCurso, bytes32 nombreSubcategoriaAnterior, bytes32 nombreSubcategoriaCurso, address indexed certificador, uint fechaHora);
  event LogSubcategoriaCursoDesactivada(uint indexed subcategoriaCurso, bytes32 nombreSubcategoriaDesactivada, address indexed certificador, uint fechaHora);
  event LogSubcategoriaCursoActivada(uint indexed subcategoriaCurso, bytes32 nombreSubcategoriaDesactivada, address indexed certificador, uint fechaHora);
  
  struct estructuraCategoriaCurso {
    bytes32 nombreCategoriaCurso;
    uint tipoCertificado;
    uint[] arregloSubcategoriaCurso;
  }

  struct estructuraImagenSubcategoria {
    uint imagenSubcategoria;
  }

  mapping(uint => estructuraImagenSubcategoria) private mapeoImagenSubcategoria;

  mapping(uint => estructuraCategoriaCurso) private mapeoCategoriaCurso;
  uint[] private arregloCategoriaCurso;
  bytes32[] private arregloNombreSubcategoriaCurso;

  //Arreglo que almacena un booleano indicando si la subcategoria existe
  bool[] private arregloActividadSubcategoriaCurso;
  
  function agregarCategoriaCurso(
              bytes32 nombreCategoriaCurso,
              uint tipoCertificado)
    public
    returns (uint categoriaCurso)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    categoriaCurso = arregloCategoriaCurso.length;
    arregloCategoriaCurso.push(categoriaCurso);
    mapeoCategoriaCurso[categoriaCurso].nombreCategoriaCurso = nombreCategoriaCurso;
    mapeoCategoriaCurso[categoriaCurso].tipoCertificado = tipoCertificado;
    emit LogCategoriaCursoCreada(categoriaCurso, nombreCategoriaCurso, msg.sender, now);
    return categoriaCurso;
  }

  function mostrarCategoriasCurso()
    public view
    returns(uint[] memory)
  {
    require(arregloCategoriaCurso.length > 0, "Actualmente no hay categorías");
    return arregloCategoriaCurso;
  }

  function describirCategoriaCurso(uint categoriaCurso)
    public view
    returns(bytes32 nombre, uint tipo)
  {
    require(arregloCategoriaCurso.length > 0, "Actualmente no hay categorías");
    return (mapeoCategoriaCurso[categoriaCurso].nombreCategoriaCurso,
            mapeoCategoriaCurso[categoriaCurso].tipoCertificado);
  }

  function modificarCategoriaCurso(uint categoriaCurso,
                                      bytes32 nombreCategoriaCurso)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(arregloCategoriaCurso.length > 0, "Actualmente no hay categorías");
    bytes32 nombreAnterior = mapeoCategoriaCurso[categoriaCurso].nombreCategoriaCurso;
    mapeoCategoriaCurso[categoriaCurso].nombreCategoriaCurso = nombreCategoriaCurso;
    emit LogCategoriaCursoModificada(categoriaCurso, nombreAnterior, nombreCategoriaCurso, msg.sender, now);
    return true;
  }

  function modificarTipoCertificadoCurso(uint categoriaCurso,
                                      uint tipoCertificado)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(arregloCategoriaCurso.length > 0, "Actualmente no hay categorías");
    mapeoCategoriaCurso[categoriaCurso].tipoCertificado = tipoCertificado;
    return true;
  }

  function eliminarUltimaCategoriaCurso()
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(arregloCategoriaCurso.length > 0, "Actualmente no hay categorías");
    uint categoriaCursoIdEliminada = arregloCategoriaCurso.length-1;
    require(!existenciaSubcategoriasCurso(categoriaCursoIdEliminada), "Categoría ya contiene subcategorías, a riesgo de vulnerar otros cursos no se puede eliminar, modifíquela mejor.");
    bytes32 nombreCategoriaCursoIdEliminada = mapeoCategoriaCurso[categoriaCursoIdEliminada].nombreCategoriaCurso;
    arregloCategoriaCurso.length--;
    emit LogCategoriaCursoEliminada(categoriaCursoIdEliminada, nombreCategoriaCursoIdEliminada, msg.sender, now);
    return true;
  }

  function existenciaCategoriaCurso(uint categoriaCurso)
    public view
    returns (bool existencia)
  {
    require(arregloCategoriaCurso.length > 0, "No existen categorías");
    if (categoriaCurso <= arregloCategoriaCurso.length-1)
      return true;
  }

  function agregarSubcategoriaCurso(
              uint categoriaCurso,
              bytes32 nombreSubcategoriaCurso,
              uint imagenSubcategoria)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(existenciaCategoriaCurso(categoriaCurso), "La categoría no existe");
    uint subcategoriaValor = arregloNombreSubcategoriaCurso.length;
    mapeoCategoriaCurso[categoriaCurso].arregloSubcategoriaCurso.push(subcategoriaValor);
    arregloNombreSubcategoriaCurso.push(nombreSubcategoriaCurso);
    arregloActividadSubcategoriaCurso.push(true);
    mapeoImagenSubcategoria[subcategoriaValor].imagenSubcategoria = imagenSubcategoria;
    (bytes32 nombreCategoria,) = describirCategoriaCurso(categoriaCurso);
    emit LogSubcategoriaCursoCreada(categoriaCurso, nombreCategoria, subcategoriaValor, nombreSubcategoriaCurso, imagenSubcategoria, msg.sender, now);
    return true;
  }

  function existenciaSubcategoriasCurso(uint categoriaCurso)
    public view
    returns (bool existencia)
  {
    if (mapeoCategoriaCurso[categoriaCurso].arregloSubcategoriaCurso.length > 0)
      return true;
  }

  function mostrarSubcategoriasCurso(uint categoriaCurso)
    public view
    returns(uint[] memory)
  {
    require(existenciaSubcategoriasCurso(categoriaCurso), "La categoría no posee subcategorías");
    return mapeoCategoriaCurso[categoriaCurso].arregloSubcategoriaCurso;
  }

  function actividadSubcategoriaCurso(uint subcategoriaCurso)
    public view
    returns (bool actividad)
  {
    if (arregloActividadSubcategoriaCurso[subcategoriaCurso] == true)
      return true;
    else
      return false;
  }

  function describirSubcategoriaCurso(uint subcategoriaCurso)
    public view
    returns(bytes32, uint)
  {
    require(actividadSubcategoriaCurso(subcategoriaCurso), "La subcategoria no existe o está inactiva");
    return (arregloNombreSubcategoriaCurso[subcategoriaCurso],
            mapeoImagenSubcategoria[subcategoriaCurso].imagenSubcategoria);
  }

  function describirSubcategoriaCursoTodas(uint subcategoriaCurso)
    public view
    returns(bytes32, uint)
  {
    return (arregloNombreSubcategoriaCurso[subcategoriaCurso],
            mapeoImagenSubcategoria[subcategoriaCurso].imagenSubcategoria);
  }

  function modificarSubcategoriaCurso(uint subcategoriaCurso,
                                      bytes32 nombreSubcategoriaCurso)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(actividadSubcategoriaCurso(subcategoriaCurso), "La subcategoría no existe");
    bytes32 nombreSubcategoriaAnterior = arregloNombreSubcategoriaCurso[subcategoriaCurso];
    arregloNombreSubcategoriaCurso[subcategoriaCurso] = nombreSubcategoriaCurso;
    emit LogSubcategoriaCursoModificada(subcategoriaCurso, nombreSubcategoriaAnterior, nombreSubcategoriaCurso, msg.sender, now);
    return true;
  }

  function modificarImagenSubcategoriaCurso(uint subcategoriaCurso,
                                      uint imagenSubcategoria)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    mapeoImagenSubcategoria[subcategoriaCurso].imagenSubcategoria = imagenSubcategoria;
    return true;
  }

  function desactivarSubcategoriaCurso(uint subcategoriaCurso)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(actividadSubcategoriaCurso(subcategoriaCurso), "La subcategoría no existe o ya está desactivada");
    bytes32 nombreSubcategoriaDesactivada = arregloNombreSubcategoriaCurso[subcategoriaCurso];
    arregloActividadSubcategoriaCurso[subcategoriaCurso] = false;
    emit LogSubcategoriaCursoDesactivada(subcategoriaCurso, nombreSubcategoriaDesactivada, msg.sender, now);
    return true;
  }

  function activarSubcategoriaCurso(uint subcategoriaCurso)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(arregloNombreSubcategoriaCurso.length-1 >= subcategoriaCurso, "La subcategoría no existe");
    require(!actividadSubcategoriaCurso(subcategoriaCurso), "La subcategoría ya está activada");
    bytes32 nombreSubcategoriaActivada = arregloNombreSubcategoriaCurso[subcategoriaCurso];
    arregloActividadSubcategoriaCurso[subcategoriaCurso] = true;
    emit LogSubcategoriaCursoActivada(subcategoriaCurso, nombreSubcategoriaActivada, msg.sender, now);
    return true;
  }







  struct estructuraCursos {
    bytes32 nombreCurso;     //Nombre del curso
    uint categoriaCurso;    //Categoría a la que está asociada el curso
    uint subcategoriaCurso; //Subcategoría del curso dentro de la categoría
    uint duracion;              //Año de creación del curso
  }

  //La clave del arreglo y el mapeo será el Identificador Único del Curso
  address[] private arregloCursos; //Arreglo de autorizados (address) para certificar un curso
  mapping(uint => estructuraCursos) private mapeoCursos;

  function autorizadoCurso(uint identificadorCurso)
    public view
    returns (address autorizado)
  {
    return arregloCursos[identificadorCurso];
  }

  function mostrarCurso(uint identificadorCurso)
    public view
    returns(bytes32 nombreCurso,
            uint categoriaCurso,
            uint subcategoriaCurso,
            uint duracion,
            address autorizado)
  {
    require(existenciaCurso(identificadorCurso), "Curso no existe");
    nombreCurso = mapeoCursos[identificadorCurso].nombreCurso;
    categoriaCurso = mapeoCursos[identificadorCurso].categoriaCurso;
    subcategoriaCurso = mapeoCursos[identificadorCurso].subcategoriaCurso;
    duracion = mapeoCursos[identificadorCurso].duracion;
    autorizado = autorizadoCurso(identificadorCurso);
    return( nombreCurso,
            categoriaCurso,
            subcategoriaCurso,
            duracion,
            autorizado);
  }

  function mostrarCantidadDeCursos()
    public view
    returns(uint)
  {
    return arregloCursos.length;
  }

  function agregarCurso(
              bytes32 nombreCurso,
              uint categoriaCurso,
              uint subcategoriaCurso,
              uint duracion,
              address autorizado)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    uint identificadorCurso = arregloCursos.length;
    mapeoCursos[identificadorCurso].nombreCurso = nombreCurso;
    mapeoCursos[identificadorCurso].categoriaCurso = categoriaCurso;
    mapeoCursos[identificadorCurso].subcategoriaCurso = subcategoriaCurso;
    mapeoCursos[identificadorCurso].duracion = duracion;
    arregloCursos.push(autorizado);
    emit LogCursoCreado(msg.sender, identificadorCurso, nombreCurso, categoriaCurso, subcategoriaCurso, duracion, autorizado, now);
    return true;
  }

  function existenciaCurso(uint identificadorCurso)
    public view
    returns (bool existencia)
  {
    if (arregloCursos[identificadorCurso] != address(0))
      return true;
  }

  function eliminarCurso(uint identificadorCurso)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(existenciaCurso(identificadorCurso), "Curso no existe o está invalidado");
    arregloCursos[identificadorCurso] = address(0);
    emit LogCursoEliminado(msg.sender, identificadorCurso, mapeoCursos[identificadorCurso].nombreCurso, now);
    return true;
  }

  function modificarCurso(
              uint identificadorCurso,
              bytes32 nombreCurso,
              uint categoriaCurso,
              uint subcategoriaCurso,
              uint duracion,
              address autorizado)
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require (existenciaCurso(identificadorCurso), "Curso no existe o está invalidado");
    mapeoCursos[identificadorCurso].nombreCurso = nombreCurso;
    mapeoCursos[identificadorCurso].categoriaCurso = categoriaCurso;
    mapeoCursos[identificadorCurso].subcategoriaCurso = subcategoriaCurso;
    mapeoCursos[identificadorCurso].duracion = duracion;
    arregloCursos[identificadorCurso] = autorizado;
    emit LogCursoModificado(msg.sender,
                        identificadorCurso,
                        nombreCurso,
                        categoriaCurso,
                        subcategoriaCurso,
                        duracion,
                        autorizado,
                        now);
    return true;
  }
}