// --------------------------- REGISTRO ---------------------------
async function registrarUsuario() {
    const nombre = document.getElementById("nombre").value.trim();
    const apellido = document.getElementById("apellido").value.trim();
    const correo = document.getElementById("correo").value.trim();
    const telefono = document.getElementById("telefono").value.trim();
    const contrasena = document.getElementById("contrasena").value.trim();

    if (!nombre || !apellido || !correo || !telefono || !contrasena) {
        alert("Por favor, complete todos los campos.");
        return;
    }

    const response = await fetch('http://127.0.0.1:5000/api/usuarios/registro', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nombre, apellido, correo, telefono, contrasena })
    });

    const data = await response.json();
    alert(JSON.stringify(data));

    if (response.ok) {
        mostrarLogin();
    }
}

// --------------------------- LOGIN ----------------------------------

// --------------------------- CERRAR SESIÓN ---------------------------
function cerrarSesion() {
    localStorage.clear();
    mostrarLogin();
    alert("Sesión cerrada");
}

// --------------------------- OBTENER USUARIOS ---------------------------
function obtenerUsuarios() {
    console.log("Función obtenerUsuarios aún no implementada");
}

// --------------------------- MOSTRAR CHAT ---------------------------
function mostrarChat(usuario_id) {
    localStorage.setItem('usuario_id', usuario_id);
    document.getElementById("chat").style.display = 'block';
    document.getElementById("registro-section").style.display = 'none';
    document.getElementById("login-section").style.display = 'none';
    document.getElementById("chat-header").querySelector("h3").textContent =
        "Bienvenido " + localStorage.getItem("nombre");
    obtenerUsuarios();
}

// --------------------------- CAMBIAR DE VISTA ---------------------------
function mostrarRegistro() {
    document.getElementById("registro-section").style.display = 'block';
    document.getElementById("login-section").style.display = 'none';
    document.getElementById("chat").style.display = 'none';
}

function mostrarLogin() {
    document.getElementById("registro-section").style.display = 'none';
    document.getElementById("login-section").style.display = 'block';
    document.getElementById("chat").style.display = 'none';
}
