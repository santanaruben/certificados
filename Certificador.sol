pragma solidity ^0.5.0;

//import "../node_modules/openzeppelin-eth/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";

contract Certificador is Ownable {

  address internal administrador;
  address internal administradorApunta;

  struct estructuraCertificadores {
    bytes32 nombre;
    address apunta;
    uint indice;
  }

  address[] internal arregloCertificadores;

  mapping(address => estructuraCertificadores) internal mapeoCertificadores;

  using Roles for Roles.Role;
  Roles.Role private certificadores;
  
  event LogCertificador(bytes2 actividad, address indexed cuenta, bytes32 nombreCertificador, uint fechaHora);
  event LogCertificadorNombreModificado(address indexed certificador, bytes32 nombreAnterior, bytes32 nombreNuevo, uint fechaHora); 
  event LogCertificadorCuentaModificada(address indexed cuentaAnterior, address indexed cuentaNueva, uint fechaHora);

  function comprobarCertificador(address cuenta)
    public view
    returns(bool)
  {
    return certificadores.has(cuenta);
  }

  modifier esCertificador() {
        require(comprobarCertificador(msg.sender),"Sin Rol");
        _;
    }

  function asignarCertificador(address certificador, bytes32 nombreCertificador)
    public onlyOwner
  {
    require(!certificadores.has(certificador), "Tiene rol");
    require(certificador != address(0), "0 no");
    if (administrador != owner())
      administrador = owner();
    mapeoCertificadores[certificador].nombre = nombreCertificador;
    mapeoCertificadores[certificador].apunta = administrador;
    mapeoCertificadores[certificador].indice = arregloCertificadores.push(certificador)-1;
    certificadores.add(certificador);
    //En caso de que no sea el primer certificador creado, hacer que el anterior apunte a este
    if (mapeoCertificadores[certificador].indice > 0)
    {
      uint indiceAnterior = mapeoCertificadores[certificador].indice - 1;
      address certificadorAnterior = arregloCertificadores[indiceAnterior];
      mapeoCertificadores[certificadorAnterior].apunta = certificador;
    }
    //Si es el primer certificador entonces el administrador debe apuntar a el
    else
    {
      administradorApunta = certificador;
    }
    emit LogCertificador("C", certificador, nombreCertificador, now);
  }

  function removerCertificador(address certificador)
    public onlyOwner
  {
    require(certificadores.has(certificador), "Sin rol");
    uint filaAEliminar = mapeoCertificadores[certificador].indice;
    bytes32 nombreCertificador = mapeoCertificadores[certificador].nombre;
    //Si voy a eliminar el primer certificador
    if (filaAEliminar == 0)
    {
      //Si existen mas certificadores
      if (arregloCertificadores.length > 1)
        administradorApunta = arregloCertificadores[1];
      //Si solo existe uno
      else
        administradorApunta = address(0);
    }
    //Si la fila a eliminar no es la fila 1
    else
    {
      //Si el arreglo contiene 2 o más certificadores
      if (arregloCertificadores.length > 1)
      {
        //Si es el último, el anterior apuntará a Administrador
        if(filaAEliminar == arregloCertificadores.length-1)
          mapeoCertificadores[arregloCertificadores[filaAEliminar-1]].apunta = administrador;
        //Si no es el último, el anterior apuntará al siguiente
        else
          mapeoCertificadores[arregloCertificadores[filaAEliminar-1]].apunta = arregloCertificadores[filaAEliminar+1];
      }
    }
    //Si es la ultima no precisa entrar en el while, solo la elimina
    //Este while reescribe todo el arreglo para que quede ordenado
    while (filaAEliminar < arregloCertificadores.length-1)
    {
      address contenidoAMover = arregloCertificadores[filaAEliminar+1];
      arregloCertificadores[filaAEliminar] = contenidoAMover;
      mapeoCertificadores[contenidoAMover].indice = filaAEliminar;
      filaAEliminar++;
    }
    arregloCertificadores.length--;
    certificadores.remove(certificador);
    emit LogCertificador("E", certificador, nombreCertificador, now);
  }

  function modificarNombreCertificador(
        address certificador,
        bytes32 nombreNuevo)
    public onlyOwner
  {
    require(certificadores.has(certificador), "No existe");
    bytes32 nombreAnterior = mapeoCertificadores[certificador].nombre;
    mapeoCertificadores[certificador].nombre = nombreNuevo;
    emit LogCertificadorNombreModificado(certificador, nombreAnterior, nombreNuevo, now);
  }

  function modificarCuentaCertificador(
        address cuentaAnterior,
        address cuentaNueva)
    public onlyOwner
  {
    require(certificadores.has(cuentaAnterior), "No existe");
    mapeoCertificadores[cuentaNueva].indice = mapeoCertificadores[cuentaAnterior].indice;
    mapeoCertificadores[cuentaNueva].nombre = mapeoCertificadores[cuentaAnterior].nombre;
    mapeoCertificadores[cuentaNueva].apunta = mapeoCertificadores[cuentaAnterior].apunta;
    arregloCertificadores[mapeoCertificadores[cuentaNueva].indice] = cuentaNueva;
    certificadores.remove(cuentaAnterior);
    certificadores.add(cuentaNueva);
    //Si es el primer certificador, hacer que administrador apunte a nueva cuenta
    if (mapeoCertificadores[cuentaNueva].indice == 0)
      administradorApunta = cuentaNueva;
    //Sino, modificar el apunte del certificador anterior, a esta nueva cuenta
    else
    {
      uint indiceAnterior = mapeoCertificadores[cuentaNueva].indice-1;
      address cuentaAModificarApunte = arregloCertificadores[indiceAnterior];
      mapeoCertificadores[cuentaAModificarApunte].apunta = cuentaNueva;
    }
    emit LogCertificadorCuentaModificada(cuentaAnterior, cuentaNueva, now);
  }

  //Muestra el arreglo de certificadores (Direcciones)
  function mostrarCertificadores()
    public view
    returns(address[] memory)
  {
    return (arregloCertificadores);
  }

  //Coloca la dirección, el nombre del certificador buscado y a quien apunta
  function describirCertificador(address certificador)
    public view
    returns(bytes32, bytes32)
  {
    require(certificadores.has(certificador), "Sin rol");
    bytes32 apunta;
    address direccionApunta = mapeoCertificadores[certificador].apunta;
    if (direccionApunta == administrador)
      apunta = "Admin";
    else
      apunta = mapeoCertificadores[direccionApunta].nombre;
    return (mapeoCertificadores[certificador].nombre, apunta);
  }

}