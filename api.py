from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import pyodbc

app = Flask(__name__, static_folder="static", template_folder="templates")
CORS(app, origins=["http://127.0.0.1:3000", "http://127.0.0.1:5000"])

# --------------------- CONEXIÓN BD ---------------------
def conectar_bd():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=MensajeriaBDTest;"
        "Trusted_Connection=yes;"
    )

@app.route("/")
def mostrar_index():
    return render_template("index.html")

# --------------------- REGISTRO ---------------------
@app.route("/api/usuarios/registro", methods=["POST"])
def registrar_usuario():
    data = request.json
    nombre = data.get("nombre")
    apellido = data.get("apellido")
    correo = data.get("correo")
    telefono = data.get("telefono")
    contrasena = data.get("contrasena")

    if not all([nombre, apellido, correo, telefono, contrasena]):
        return jsonify({"error": "Faltan campos"}), 400

    try:
        conn = conectar_bd()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_RegistrarUsuario ?, ?, ?, ?, ?",
                    nombre, apellido, contrasena, correo, telefono)
        conn.commit()
        return jsonify({"mensaje": "Usuario registrado correctamente"}), 200
    except pyodbc.IntegrityError:
        return jsonify({"error": "Correo o teléfono ya registrados"}), 409
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()
        

# --------------------- LOGIN --------------------------

# --------------------- OTRAS RUTAS ---------------------
if __name__ == "__main__":
    app.run(debug=True)
