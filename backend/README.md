# Backend con Flask: Documentación Completa

## 1. Propósito y Arquitectura

Este directorio contiene el servidor API RESTful para la aplicación de monitoreo de Parkinson. Ha sido construido con **Flask**, un micro-framework de Python, y su principal responsabilidad es servir como una capa de persistencia y lógica de negocio.

Las funciones clave del backend son:

-   **Servir una API REST:** Expone un conjunto de endpoints (rutas) a los que la aplicación de Flutter puede llamar para obtener o enviar datos.
-   **Autenticación de Usuarios:** Gestiona el registro y el inicio de sesión de los usuarios.
-   **Persistencia de Datos:** Se conecta a una base de datos SQLite para almacenar y recuperar información sobre usuarios, pacientes, médicos y resultados de pruebas.
-   **Lógica de Negocio:** Centraliza las reglas y operaciones del sistema.

### Tecnologías Utilizadas

-   **Flask:** Es el framework web principal. Gestiona las rutas, las peticiones y las respuestas.
-   **SQLAlchemy (ORM):** Actúa como un traductor entre los objetos de Python y las tablas de la base de datos. Nos permite definir la estructura de la base de datos usando clases de Python (Modelos) y realizar consultas de forma segura y programática.
-   **Flask-Migrate:** Es una extensión para gestionar las "migraciones" de la base de datos. Cuando modificamos un modelo (ej: añadir una columna a la tabla `Usuario`), Flask-Migrate nos ayuda a actualizar la base de datos sin perder los datos existentes.
-   **Flask-CORS:** Gestiona las políticas de CORS, permitiendo que nuestra app de Flutter (que se ejecuta en un dominio diferente) pueda comunicarse con este servidor.

---

## 2. Estructura de la Base de Datos (Modelos)

La base de datos se define en `app.py` a través de los siguientes modelos de SQLAlchemy:

-   **`Usuario`**: La tabla central que contiene la información básica de cualquier persona registrada en el sistema.
    -   `usuario_id` (Clave Primaria)
    -   `nombre`, `correo`, `contrasena`, `rol` (`Paciente` o `Médico`)

-   **`Paciente`**: Contiene información específica de los usuarios con rol de paciente. Está vinculada a un `Usuario` a través de una relación "uno a uno".
    -   `paciente_id` (Clave Primaria)
    -   `usuario_id` (Clave Foránea a `Usuario`)
    -   `edad`, `genero`, `fecha_diagnostico`, `contacto_emergencia`

-   **`Medico`**: Similar a `Paciente`, contiene información específica de los médicos.

-   **`ResultadoPrueba`**: Almacena los resultados de cada prueba realizada por un paciente.

-   *Otros modelos* como `RelacionMedicoPaciente` o `Consentimiento` están definidos para futuras ampliaciones.

Cada modelo tiene un método `.to_dict()` que se utiliza para serializar el objeto de Python a un formato JSON que pueda ser enviado a través de la API.

---

## 3. API Endpoints (Rutas)

El archivo `app.py` define las siguientes rutas:

-   **`POST /registro.json`**: 
    -   **Propósito:** Registrar un nuevo usuario. 
    -   **Payload (JSON):** `nombre`, `correo`, `contrasena`, `rol`.
    -   **Respuesta:** El objeto del nuevo usuario creado.

-   **`POST /login.json`**:
    -   **Propósito:** Validar las credenciales de un usuario.
    -   **Payload (JSON):** `correo`, `contrasena`.
    -   **Respuesta:** El objeto del usuario si las credenciales son correctas, incluyendo su perfil de paciente/médico si existe.

-   **`GET /pacientes.json`**: 
    -   **Propósito:** Obtener una lista de todos los pacientes registrados.

-   **`POST /resultados.json`**: 
    -   **Propósito:** Guardar el resultado de una nueva prueba.

---

## 4. Guía de Ejecución

Sigue estos pasos para configurar y ejecutar el servidor localmente.

1.  **Prerrequisitos:**
    -   Tener [Python](https://www.python.org/downloads/) instalado (versión 3.8 o superior).

2.  **Navegar al Directorio:**
    Desde una terminal, sitúate en esta carpeta (`backend/`).

3.  **Crear y Activar el Entorno Virtual:**
    Esto aísla las dependencias del proyecto.
    ```sh
    # Crear el entorno
    python -m venv venv

    # Activar en Windows
    .\venv\Scripts\activate

    # Activar en macOS/Linux
    source venv/bin/activate
    ```

4.  **Instalar Dependencias:**
    *Si existe un archivo `requirements.txt`, puedes usar `pip install -r requirements.txt`. Si no, puedes crearlo con los siguientes comandos:*
    ```sh
    pip install Flask Flask-SQLAlchemy Flask-Migrate Flask-Cors
    pip freeze > requirements.txt
    ```

5.  **Inicializar la Base de Datos (Solo la primera vez):**
    Estos comandos crean el archivo `app.db` y las tablas basadas en los modelos.
    ```sh
    flask db init
    flask db migrate -m "Creación inicial de tablas"
    flask db upgrade
    ```

6.  **Ejecutar el Servidor:**
    ```sh
    flask run
    ```
    El servidor se iniciará y estará escuchando en `http://127.0.0.1:5000`.
