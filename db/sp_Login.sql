CREATE OR ALTER PROCEDURE sp_LoginUsuario (
    @param_Identificador NVARCHAR(100), -- Correo o n�mero de tel�fono
    @param_Contrasenna NVARCHAR(100)    -- Contrase�a en texto plano
)
AS
BEGIN
    DECLARE @UsuarioID INT;
    DECLARE @ContrasennaGuardada VARBINARY(128);
    DECLARE @TokenNuevo NVARCHAR(255);

    BEGIN TRY
        -- Buscar al usuario por correo o n�mero
        SELECT TOP 1 
            @UsuarioID = UsuarioID,
            @ContrasennaGuardada = Contrasenna
        FROM Usuario
        WHERE (Correo = @param_Identificador OR NumeroTelefono = @param_Identificador)
        AND Estado = 0;

        -- Validar existencia
        IF @UsuarioID IS NULL
        BEGIN
            RAISERROR('Usuario no encontrado o eliminado.', 16, 1);
            RETURN;
        END

        -- Abrir la llave sim�trica
        OPEN SYMMETRIC KEY Usuario_Key_01
        DECRYPTION BY CERTIFICATE Usuario_KEY_CERT;

        -- Validar la contrase�a
        IF CONVERT(NVARCHAR(100), DECRYPTBYKEY(@ContrasennaGuardada)) != @param_Contrasenna
        BEGIN
            CLOSE SYMMETRIC KEY Usuario_Key_01;
            RAISERROR('Contrase�a incorrecta.', 16, 1);
            RETURN;
        END

        -- Cerrar la llave sim�trica
        CLOSE SYMMETRIC KEY Usuario_Key_01;

        -- Verificar si ya existe una sesi�n activa
        IF EXISTS (
            SELECT 1 FROM Sesion
            WHERE UsuarioID = @UsuarioID AND Activa = 1
        )
        BEGIN
            RAISERROR('Ya hay una sesi�n activa para este usuario.', 16, 1);
            RETURN;
        END

        -- Generar un nuevo token �nico
        SET @TokenNuevo = CONVERT(NVARCHAR(255), NEWID());

        -- Crear nueva sesi�n con el token
        INSERT INTO Sesion (UsuarioID, Token, FechaInicio, Activa)
        VALUES (@UsuarioID, @TokenNuevo, GETDATE(), 1);

        -- Retornar datos del usuario y token para la aplicaci�n
        SELECT 
            U.UsuarioID,
            U.Nombre,
            U.Apellido,
            U.Correo,
            U.NumeroTelefono,
            S.Token
        FROM Usuario U
        JOIN Sesion S ON U.UsuarioID = S.UsuarioID
        WHERE U.UsuarioID = @UsuarioID AND S.Token = @TokenNuevo;

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO


EXEC sp_LoginUsuario
    @param_Identificador = '33333333',  -- o el n�mero
    @param_Contrasenna = '12345';
