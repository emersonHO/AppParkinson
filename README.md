# App de Monitoreo de Parkinson: Documentación Completa

## 1. Visión General del Proyecto

Esta es una app diseñado para el monitoreo y seguimiento de pacientes con la enfermedad de Parkinson. El objetivo es proporcionar una herramienta intuitiva tanto para pacientes como para médicos, permitiendo la realización de pruebas motoras y cognitivas, y la visualización de los resultados a lo largo del tiempo.

El proyecto se divide en dos componentes principales y desacoplados:

1.  **Frontend (Flutter):** Una aplicación moderna y reactiva que funciona en web y dispositivos móviles desde una única base de código.
2.  **Backend (Flask):** Un servidor API ligero y robusto que gestiona la base de datos, la autenticación y la lógica de negocio.

---

## 2. Arquitectura del Frontend (Flutter)

La aplicación de Flutter está construida siguiendo el patrón de diseño **MVVM (Model-View-ViewModel)**, que garantiza una separación clara entre la interfaz de usuario, la lógica de estado y la fuente de datos.

La gestión del estado se implementa utilizando el paquete `provider`, que permite que los ViewModels sean accesibles en todo el árbol de widgets de forma eficiente.

### Flujo de Datos (Ejemplo: Inicio de Sesión)

Para entender cómo funcionan las piezas juntas, aquí tienes el flujo de un inicio de sesión:

1.  **Vista (`login_form_screen.dart`):** El usuario introduce su correo y contraseña en los `TextFields`.
2.  **Llamada al ViewModel:** Al pulsar el botón "Iniciar Sesión", la vista no hace ningún cálculo. Simplemente invoca una función del ViewModel: `loginViewModel.validateLogin()`.
3.  **ViewModel (`login_viewmodel.dart`):**
    -   Recibe la llamada y actualiza su estado (ej: `isLoading = true`).
    -   Notifica a la vista que el estado ha cambiado (usando `notifyListeners()`), lo que provoca que la UI muestre un indicador de carga.
    -   Llama al `ApiService` para realizar la petición real al backend: `_apiService.validarUsuario(correo, contrasena)`.
4.  **Servicio (`api_service.dart`):**
    -   Construye y ejecuta una petición HTTP POST a la ruta `/login.json` del servidor Flask.
    -   Espera la respuesta del servidor. Si la respuesta es exitosa (código 200), decodifica el JSON recibido.
5.  **Modelo (`usuario.dart`):**
    -   El `ApiService` utiliza el constructor `Usuario.fromJson(json)` para convertir el mapa de datos JSON en un objeto Dart fuertemente tipado (`Usuario`).
6.  **Retorno y Actualización de Estado:**
    -   El `ApiService` devuelve el objeto `Usuario` al `LoginViewModel`.
    -   El ViewModel recibe el objeto, lo guarda como el `currentUser`, cambia `isLoading` a `false` y notifica a la vista de nuevo.
7.  **Reacción de la Vista:** La vista, al ser notificada, reconstruye su UI. Como ahora hay un `currentUser`, la lógica de navegación redirige al usuario a la `home_screen.dart`.

### Estructura de Carpetas (`lib/`)

-   **`main.dart`**: Punto de entrada de la aplicación. Responsable de:
    -   Configurar el `MultiProvider` para que todos los ViewModels estén disponibles para la app.
    -   Definir la tabla de rutas de navegación (ej: `/login`, `/home`).
    -   Establecer el tema global de la aplicación.

-   **`screens/`**: Contiene los widgets que representan una pantalla completa. Estas son las "Vistas" en MVVM. Son responsables de la apariencia y de capturar las interacciones del usuario, pero delegan toda la lógica a los ViewModels.

-   **`viewmodels/`**: Los "cerebros" de las vistas. Contienen la lógica de estado y las funciones que las vistas pueden llamar. Se comunican con los servicios y actualizan su estado, notificando a las vistas para que se redibujen.

-   **`models/`**: Define las estructuras de datos puras de la aplicación (ej: `Usuario`, `Paciente`, `Resultado`). Su principal responsabilidad es proporcionar un método `fromJson` para parsear los datos de la API.

-   **`services/`**: Clases que encapsulan la comunicación con fuentes de datos externas. En este proyecto, su único miembro es `api_service.dart`, que centraliza todas las llamadas HTTP al backend.

---

## 3. Guía de Ejecución

Para ejecutar la aplicación, **ambos componentes (backend y frontend) deben estar en funcionamiento simultáneamente.**

### Paso A: Iniciar el Backend

Primero, asegúrate de que el servidor de Flask esté corriendo. Para ello, abre una terminal separada y sigue las instrucciones detalladas en el archivo `backend/README.md`.

### Paso B: Iniciar el Frontend

Una vez que el backend esté activo, puedes ejecutar la aplicación de Flutter.

1.  **Prerrequisitos:**
    -   Tener el [SDK de Flutter](https://docs.flutter.dev/get-started/install) instalado.

2.  **Obtener dependencias:**
    Desde la raíz del proyecto, ejecuta:
    ```sh
    flutter pub get
    ```

3.  **Ejecutar la aplicación:**
    Se recomienda ejecutar en un navegador para el desarrollo.
    ```sh
    flutter run -d chrome
    ```
