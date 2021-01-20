pragma solidity ^0.5.0;

//import "../node_modules/openzeppelin-eth/contracts/ownership/Ownable.sol";
// import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";
import "./CertificadorCurso.sol";

contract Usuario is CertificadorCurso {

  event LogUsuarioAgregado(uint indexed cedula, bytes32 nombre, address indexed certificador, uint fechaHora);
  event LogUsuarioEditado(uint indexed cedula, address indexed certificador, bytes32 nombreAnterior, bytes32 nombreNuevo, uint fechaHora);
  event LogUsuarioEliminado(uint indexed cedula, address indexed certificador, bytes32 nombreUsuarioEliminado, uint fechaHora);

  struct estructuraUsuarios {
    bytes32 nombre;
    uint indice;
  }

  uint[] private arregloUsuarios;
  mapping(uint => estructuraUsuarios) private mapeoEstructuraUsuarios;

  function existenciaUsuario(uint cedula)
    public view
    returns(bool existencia) 
  {
    if(arregloUsuarios.length == 0) return false;
    return (arregloUsuarios[mapeoEstructuraUsuarios[cedula].indice] == cedula);
  }

  function agregarUsuario(
    uint cedula, 
    bytes32 nombre) 
    public
    returns (bool exito)
  {
    require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
    require(cedula != 0, "Cedula no puede ser igual a 0");
    require(!existenciaUsuario(cedula),"Usuario ya existe");
    mapeoEstructuraUsuarios[cedula].nombre = nombre;
    mapeoEstructuraUsuarios[cedula].indice = arregloUsuarios.push(cedula)-1;
    emit LogUsuarioAgregado(cedula, nombre, msg.sender, now);
    return true;
  }

  function obtenerUsuario(uint cedula)
    public view
    returns(bytes32 nombre)
  {
    require(existenciaUsuario(cedula),"Usuario no existe");
    return mapeoEstructuraUsuarios[cedula].nombre;
  }

  function editarUsuario(uint cedula, bytes32 nombreNuevo) 
        public
        returns(bool exito)
    {
        require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
        require(existenciaUsuario(cedula),"Usuario no existe");
        bytes32 nombreAnterior = mapeoEstructuraUsuarios[cedula].nombre;
        mapeoEstructuraUsuarios[cedula].nombre = nombreNuevo;
        emit LogUsuarioEditado(cedula, msg.sender, nombreAnterior, nombreNuevo, now);
        return true;
    }

    function eliminarUsuario(uint cedula) 
        public
        returns(bool exito)
    {
        require(comprobarCertificadorCurso(msg.sender), "Usted no posee el rol certificador de curso");
        require(existenciaUsuario(cedula),"Usuario no existe");
        uint filaAEliminar = mapeoEstructuraUsuarios[cedula].indice;
        bytes32 nombreUsuarioEliminado = mapeoEstructuraUsuarios[cedula].nombre;
        uint claveAMover = arregloUsuarios[arregloUsuarios.length-1];
        arregloUsuarios[filaAEliminar] = claveAMover;
        mapeoEstructuraUsuarios[claveAMover].indice = filaAEliminar; 
        arregloUsuarios.length--;
        emit LogUsuarioEliminado(cedula, msg.sender, nombreUsuarioEliminado, now);
        return true;
    }

}