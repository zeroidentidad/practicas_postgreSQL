(function(window, document){
  'use strict';

  var myDataRef = new Firebase('https://softcun-dbdemo.firebaseio.com/estudiantes'),
      boton  = $('btnEnviar'),
      name_get   = $('nombre_get'),
      age_get    = $('edad_get'),
      active_get = $('activo_get'),
      listado    = $('lista');

  myDataRef.on('child_added', function(elemento){
    var data = elemento.val();
    listado.innerHTML += elemento.key();
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.nombre;
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.edad;
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.activo?'Si':'No';
    listado.innerHTML += '<hr>';
  });

  myDataRef.on('child_changed', function(elemento) {
    var data = elemento.val();
    listado.innerHTML += 'Ha cambiado el valor del objeto: ';
    listado.innerHTML += elemento.key();
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.nombre;
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.edad;
    listado.innerHTML += '<br/>';
    listado.innerHTML += data.activo?'Si':'No';
    listado.innerHTML += '<hr>';
  });

  boton.addEventListener('click', enviar, false);

  function enviar(){
    var estudiante1, estudiante2, estudiante3;

    estudiante1 = {
      nombre: "Jesus Ferrer",
      edad: 26,
      activo: true
    };

    estudiante2 = {
      nombre: "Vero tonta",
      edad: 25,
      activo: false
    };

    estudiante3 = {
      nombre: "Nato loco",
      edad: 27,
      activo: true
    };

    myDataRef.push(estudiante1);
    myDataRef.push(estudiante2);
    myDataRef.push(estudiante3);

  }

  function $(id) {
    return document.getElementById(id);
  }

})(window, document);
