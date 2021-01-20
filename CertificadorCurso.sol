pragma solidity ^0.5.0;

//import "../node_modules/openzeppelin-eth/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";

contract CertificadorCurso is Ownable {

  address internal administrador;

  struct estructuraCertificadoresCurso {
    bytes32 nombre;
    uint indice;
  }

  address[] private arregloCertificadoresCurso;

  mapping(address => estructuraCertificadoresCurso) private mapeoCertificadoresCurso;

  using Roles for Roles.Role;
  Roles.Role private certificadoresCurso;
  
  event LogCertificadorCursoAgregado(address indexed cuenta, bytes32 nombreCertificadorCurso, uint fechaHora);
  event LogCertificadorCursoEliminado(address indexed cuenta, bytes32 nombreCertificadorCurso, uint fechaHora);
  event LogCertificadorCursoNombreModificado(address indexed certificadorCurso, bytes32 nombreAnterior, bytes32 nombreNuevo, uint fechaHora); 
  event LogCertificadorCursoCuentaModificada(address indexed cuentaAnterior, address indexed cuentaNueva, uint fechaHora);

  function comprobarCertificadorCurso(address cuenta)
    public view
    returns(bool existencia)
  {
    return certificadoresCurso.has(cuenta);
  }

  function asignarCertificadorCurso(address certificadorCurso, bytes32 nombreCertificadorCurso)
    public onlyOwner
    returns(bool exito)
  {
    require(!certificadoresCurso.has(certificadorCurso), "Cuenta ya posee el rol certificador de cursos");
    require(certificadorCurso != address(0), "Cuenta certificador no puede ser 0");
    if (administrador != owner())
      administrador = owner();
    mapeoCertificadoresCurso[certificadorCurso].nombre = nombreCertificadorCurso;
    mapeoCertificadoresCurso[certificadorCurso].indice = arregloCertificadoresCurso.push(certificadorCurso)-1;
    certificadoresCurso.add(certificadorCurso);
    emit LogCertificadorCursoAgregado(certificadorCurso, nombreCertificadorCurso, now);
    return true;
  }

  function removerCertificadorCurso(address certificadorCurso)
    public onlyOwner
    returns(bool exito)
  {
    require(certificadoresCurso.has(certificadorCurso), "Cuenta no posee el rol certificador de cursos");
    uint filaAEliminar = mapeoCertificadoresCurso[certificadorCurso].indice;
    bytes32 nombreCertificadorCurso = mapeoCertificadoresCurso[certificadorCurso].nombre;
    //Si es la ultima fila no precisa entrar en el while, solo la elimina
    //Este while reescribe todo el arreglo para que quede ordenado
    while (filaAEliminar < arregloCertificadoresCurso.length-1)
    {
      address contenidoAMover = arregloCertificadoresCurso[filaAEliminar+1];
      arregloCertificadoresCurso[filaAEliminar] = contenidoAMover;
      mapeoCertificadoresCurso[contenidoAMover].indice = filaAEliminar;
      filaAEliminar++;
    }
    arregloCertificadoresCurso.length--;
    certificadoresCurso.remove(certificadorCurso);
    emit LogCertificadorCursoEliminado(certificadorCurso, nombreCertificadorCurso, now);
    return true;
  }

  function modificarNombreCertificadorCurso(
        address certificadorCurso,
        bytes32 nombreNuevo)
    public onlyOwner
    returns(bool exito)
  {
    require(certificadoresCurso.has(certificadorCurso), "Certificador de cursos no existe");
    bytes32 nombreAnterior = mapeoCertificadoresCurso[certificadorCurso].nombre;
    mapeoCertificadoresCurso[certificadorCurso].nombre = nombreNuevo;
    emit LogCertificadorCursoNombreModificado(certificadorCurso, nombreAnterior, nombreNuevo, now);
    return true;
  }

  function modificarCuentaCertificadorCurso(
        address cuentaAnterior,
        address cuentaNueva)
    public onlyOwner
    returns(bool exito)
  {
    require(certificadoresCurso.has(cuentaAnterior), "Certificador de cursos no existe");
    mapeoCertificadoresCurso[cuentaNueva].indice = mapeoCertificadoresCurso[cuentaAnterior].indice;
    mapeoCertificadoresCurso[cuentaNueva].nombre = mapeoCertificadoresCurso[cuentaAnterior].nombre;
    arregloCertificadoresCurso[mapeoCertificadoresCurso[cuentaNueva].indice] = cuentaNueva;
    certificadoresCurso.remove(cuentaAnterior);
    certificadoresCurso.add(cuentaNueva);
    emit LogCertificadorCursoCuentaModificada(cuentaAnterior, cuentaNueva, now);
    return true;
  }

  //Muestra el arreglo de certificadores (Direcciones)
  function mostrarCertificadoresCurso()
    public view
    returns(address[] memory)
  {
    return (arregloCertificadoresCurso);
  }

  //Coloca la dirección y el nombre del certificador buscado
  function describirCertificadorCurso(address certificadorCurso)
    public view
    returns(bytes32 nombre)
  {
    require(certificadoresCurso.has(certificadorCurso), "Cuenta no posee el rol certificador de cursos");
    nombre = mapeoCertificadoresCurso[certificadorCurso].nombre;
    return (nombre);
  }

}