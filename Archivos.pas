Program Ejer2;
type
  palabra = string[10];
  productos = record
			num: integer;
			nom: string[30];
			cantact: integer;
			cantmin: integer;
			cantmax: integer;
			precio: real;
			end;
  archProd = file of productos;
  txtProd = text;
  
  procedure leerArchTxt(var archTxt: txtProd; var prod: productos);
    begin
      with prod do begin
        readln(ArchTxt, num);
        readln (nom);
        readln(ArchTxt, cantact, cantmin, cantmax, precio);
        write ('hola');
      end;
    end;
  
  procedure cargarArchivo(var ap: archProd);
    var archTxt: txtProd; prod: productos; archi:string;
    begin
      prod.num:= 0;
      write(ap, prod);
      writeln('Ingrese el nombre del archivo txt que desea abrir');
      readln (archi);
      assign(archTxt, archi);
      reset(archTxt);
      while(not eof(archTxt)) do begin
        leerArchTxt(archTxt, prod);
        write(ap, prod);
      end;
      close(archTxt);
      writeln('archivo creado');
    end;
    
  procedure leerNuevoProd(var prod: productos);
    begin
    with prod do begin
      writeln('Ingrese numero del producto');
      read(num);
      writeln('Ingrese nombre del producto');
      read(nom);
      writeln('Ingrese cantidad actual del producto');
      read(cantact);
      writeln('Ingrese cantidad minima del producto');
      read(cantmin);
      writeln('Ingrese cantidad maxima del producto');
      read(cantmax);
      writeln('Ingrese precio del producto');
      read(precio);
    end;
    end;
    
  procedure darAlta(var ap: archProd);
    var nueProd: productos; prod: productos;
    begin
    leerNuevoProd(nueProd);
    seek(ap, 0);
    read(ap, prod);
    if(prod.num < 0) then begin
	  seek(ap, -1*prod.num); {esa operacion me posiciona en la posicion del registro a dar de alta, como en la cabecera el campo num estaba en negativo, lo convierto en positivo}
	  read(ap, prod);
	  seek(ap, filepos(ap)-1);
	  write(ap, nueProd);
	  seek(ap, 0);
	  write(ap, prod);
	end
	else
	  if(prod.num = 0) then begin
	    seek(ap, filesize(ap));
	    write(ap, nueProd);
	  end;
    end;
	     
  procedure buscarNumProd(var ap: archProd; prod: productos; numProd: integer; var ok: boolean);
    begin
    while(prod.num <> numProd) and (not eof(ap)) do
      read(ap, prod);
    if(prod.num = numProd) then begin
      ok:= true;
      seek(ap, filepos(ap)-1);
    end
    else
      seek(ap, 0);
    end;
    
  procedure buscarProd(var ap: archProd; prod: productos; var numProd: integer; operacion: palabra);
    var ok: boolean; 
    begin
    ok:= false;
    while(not ok) do begin {ok solo sera verdadero cuando se ingrese un numero de producto valido para procesar}
      writeln('Ingrese el numero del producto a ', operacion,' , debe ser un valor mayor a 0');
      read(numProd);
      if(numProd > 0) then
        buscarNumProd(ap, prod, numProd, ok);
    end;
    end;
    
  procedure leerDatosAModificar(var nueProd: productos);
    begin
    with nueProd do begin
      writeln('Ingrese el nombre, cantidad minina, cantidad maxima y precio del producto del producto a modificar');
      readln(nom);
      read(cantact);
      read(cantmin);
      read(cantmax);
      read(precio);
    end;
    end;
    
  procedure modificarProd(var ap: archProd);
    var prod: productos; nueProd: productos; numProdModif: integer; operacion: palabra;
    begin
    seek(ap, 0);
    operacion:= 'modificar';
    buscarProd(ap, prod, numProdModif, operacion); {Me devuelve el numero del producto que se quiere modificar, me deja en la posicion del producto donde se encuentra ese producto}
    leerDatosAModificar(nueProd);
    nueProd.num:= numProdModif; {No se modifica el num de producto, hay que sobreescribir el original}
    write(ap, nueProd);
    end;
    
  procedure darBaja(var ap: archProd);
    var prod: productos; numProdBaja: integer; operacion: palabra; posBaja: integer; aux: productos;
    begin
    seek(ap, 0);
    operacion:= 'eliminar';
    buscarProd(ap, prod, numProdBaja, operacion); {Me deja posicionado en el producto a dar de baja}
    posBaja:= filepos(ap); {Obtengo la posicion del archivo a eliminar}
    read(ap, prod); {Leo lo que esta en la posicion a eliminar para mandarlo a la cabecera}
    prod.num:= -1 * prod.num; {Cambio el campo num a negativo}
    seek(ap, 0);
    read(ap, aux); {Leo el registro cabecera, antes de escribirlo}
    write(ap, prod); {Escribo lo que habia en el registro que di de baja pero con el campo negativo en la cabecera}
    seek(ap, posBaja); 
    write(ap, aux); {Lo que estaba en la cabecera pasa a estar en la posicion del registro que se dio de baja}
    end;
    
  procedure escribirTxt(var archTxt: txtProd; prod: productos);
    begin
    writeln(archTxt, prod.num, prod.nom);
    writeln(archTxt, prod.cantact, prod.cantmin, prod.cantmax, prod.precio);
    end;  
    
  procedure listarDatosEnTxt(var ap: archProd);
    var archTxt: txtProd; prod: productos;
    begin
    seek(ap, 0);
    assign(archTxt, 'reporteProductos.txt');
    rewrite(archTxt);
    while(not eof(ap)) do begin
      read(ap, prod);
      escribirTxt(archTxt, prod);
    end;
    end;
      
  {Programa Principal} 
  var ap: archProd; nomArch: string[30]; opc: byte;
  begin
    repeat
    writeln('Elija una opcion: ');
    writeln('0- Terminar el programa');
    writeln('1- Crear un archivo a traves de un txt ');
    writeln('2- Abrir un archivo existente');
    readln(opc);
    case (opc) of
      1: begin
         writeln('Ingrese un nombre para la creacion del archivo');
         read(nomArch);
         readln(nomArch);
         assign(ap, nomArch);
         rewrite(ap);
         cargarArchivo(ap);
         close(ap);
         end;
       2: begin
          assign(ap, nomArch);
          reset(ap);
          writeln('Eliga una opcion:');
          writeln('1- Dar de alta un producto');
          writeln('2- Modificar un producto');
          writeln('3- Dar de baja un producto');
          case (opc) of
            1: darAlta(ap);
            2: modificarProd(ap);
            3: darBaja(ap);
          end;
          close(ap);
          end;
        3: begin
           assign(ap, nomArch);
           reset(ap);
           listarDatosEnTxt(ap);
           close(ap);
           end;
    end;
  until(opc = 0);
  readln;
  end.
    
			
