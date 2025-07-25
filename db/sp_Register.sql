USE MensajeriaBDTest;
GO

-- Aseg�rate de tener las claves y certificados creados antes de este paso.
CREATE MASTER KEY ENCRYPTION BY PASSWORD ='1234ABCD'

-- Creacion del Certificado
CREATE CERTIFICATE Usuario_KEY_CERT
WITH SUBJECT = 'Certificado para las inserciones de Usuarios';

CREATE SYMMETRIC KEY Usuario_Key_01
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Usuario_KEY_CERT;

GO

CREATE OR ALTER PROCEDURE sp_RegistrarUsuario (
    @param_Nombre NVARCHAR(100),
    @param_Apellido NVARCHAR(100),
    @param_Contrasenna NVARCHAR(100), -- Contrase�a en texto plano
    @param_Correo NVARCHAR(100),
    @param_NumeroTelefono NVARCHAR(100)
)
AS
BEGIN
    DECLARE @ContrasennaEncriptada VARBINARY(128);

    -- Abrir la llave sim�trica para encriptar la contrase�a
    OPEN SYMMETRIC KEY Usuario_Key_01
    DECRYPTION BY CERTIFICATE Usuario_KEY_CERT;

    -- Encriptar la contrase�a
    SET @ContrasennaEncriptada = ENCRYPTBYKEY(KEY_GUID('Usuario_Key_01'), @param_Contrasenna);

    -- Insertar el nuevo usuario sin token
    INSERT INTO Usuario (Nombre, Apellido, Contrasenna, Correo, NumeroTelefono)
    VALUES (@param_Nombre, @param_Apellido, @ContrasennaEncriptada, @param_Correo, @param_NumeroTelefono);

    -- Cerrar la llave sim�trica
    CLOSE SYMMETRIC KEY Usuario_Key_01;

    PRINT 'Usuario registrado correctamente.';
END;
GO

EXEC sp_RegistrarUsuario
    @param_Nombre = 'admi1',
    @param_Apellido = 'control',
    @param_Contrasenna = '12345',
    @param_Correo = 'admi1@ucr',
    @param_NumeroTelefono = '11111111';

EXEC sp_RegistrarUsuario
    @param_Nombre = 'admi2',
    @param_Apellido = 'control',
    @param_Contrasenna = '12345',
    @param_Correo = 'admi2@ucr',
    @param_NumeroTelefono = '22222222';

	DELETE FROM Usuario
	DELETE FROM Sesion

	-- Verificar que el usuario fue insertado
SELECT UsuarioID, Nombre, Apellido, Correo, NumeroTelefono, Estado, Actualizado
FROM Usuario;

-- Verificar la sesi�n correspondiente
SELECT SesionID, UsuarioID, Token, FechaInicio, FechaFin, Activa
FROM Sesion;
