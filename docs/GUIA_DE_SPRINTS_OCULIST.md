# Guía de sprints del sistema OCULIST

## 1. Descripción general

OCULIST es una aplicación móvil desarrollada con Flutter para gestionar una óptica. Permite autenticar usuarios, administrar clientes y monturas, analizar el rostro de un cliente y recomendar hasta tres monturas compatibles mediante una prueba virtual.

### Estado general

| Sprint | Tema principal | Estado |
|---|---|---|
| Sprint 1 | Autenticación, roles y navegación | Completado |
| Sprint 2 | Gestión de clientes | Completado |
| Sprint 3 | Gestión del catálogo de monturas | Completado |
| Sprint 4 | Captura facial, recomendación y prueba virtual | Completado; falta prueba final con varias monturas |
| Sprint 5 | Historial de recomendaciones y selección | Pendiente |
| Sprint 6 | Reportes, pruebas finales y preparación de entrega | Pendiente |

## 2. Arquitectura utilizada

El código se divide por funcionalidades dentro de `lib/features`. Cada módulo utiliza, en general, tres capas:

- `data`: comunicación con Firebase y almacenamiento.
- `domain`: modelos, contratos de repositorios y excepciones.
- `presentation`: pantallas, componentes visuales y ViewModels.

Ejemplo:

```text
lib/features/clients/
├── data/
├── domain/
└── presentation/
```

También existen carpetas compartidas:

- `lib/app`: configuración principal y rutas.
- `lib/core`: tema visual y componentes reutilizables.
- `test`: pruebas automáticas.
- `firestore.rules`: permisos de la base de datos.
- `storage.rules`: permisos para almacenar imágenes.

---

# Sprint 1: Autenticación, roles y navegación

## Objetivo

Permitir que un usuario autorizado inicie sesión y entre al panel correspondiente según su rol.

## Funciones principales

- Inicio de sesión mediante correo y contraseña.
- Lectura del perfil del usuario desde Firestore.
- Verificación de usuario activo.
- Roles `optico` y `administrador`.
- Panel diferente según el rol.
- Protección de rutas privadas.
- Cierre de sesión.

## Casos de uso sencillos

### Iniciar sesión

1. El usuario escribe su correo y contraseña.
2. Firebase Authentication comprueba las credenciales.
3. Firestore obtiene el nombre, rol y estado del usuario.
4. Si está activo, el sistema abre su panel.
5. Si los datos son incorrectos, muestra un mensaje de error.

### Redirigir según el rol

- Si el usuario es óptico, abre el panel del óptico.
- Si es administrador, abre el panel administrativo.
- Si intenta abrir una pantalla no autorizada, el sistema lo redirige.

### Cerrar sesión

1. El usuario presiona “Cerrar sesión”.
2. Firebase finaliza la sesión.
3. La aplicación regresa al inicio de sesión.

## Carpetas y archivos importantes

```text
lib/features/authentication/
├── data/
│   ├── repositories/firebase_auth_repository.dart
│   ├── repositories/firestore_user_repository.dart
│   ├── services/firebase_auth_service.dart
│   └── services/firestore_user_service.dart
├── domain/
│   ├── exceptions/
│   ├── models/user_profile.dart
│   └── repositories/
└── presentation/
    ├── view_models/login_view_model.dart
    ├── view_models/session_view_model.dart
    ├── views/login_view.dart
    └── views/session_view.dart

lib/features/dashboard/
lib/app/router/app_router.dart
lib/firebase_options.dart
```

## Tecnologías utilizadas

- Firebase Authentication: autentica al usuario.
- Cloud Firestore: guarda el perfil, nombre, rol y estado.
- Provider: conecta las pantallas con los ViewModels.
- GoRouter: controla la navegación y protege rutas.

## Inventario completo de carpetas y archivos del Sprint 1

### Código creado o utilizado

~~~text
lib/
├── main.dart
├── firebase_options.dart
├── app/oculist_app.dart
├── app/router/app_router.dart
├── core/theme/app_theme.dart
├── features/startup/presentation/views/startup_view.dart
├── features/authentication/
│   ├── data/repositories/firebase_auth_repository.dart
│   ├── data/repositories/firestore_user_repository.dart
│   ├── data/services/firebase_auth_service.dart
│   ├── data/services/firestore_user_service.dart
│   ├── domain/exceptions/auth_exception.dart
│   ├── domain/exceptions/user_profile_exception.dart
│   ├── domain/models/user_profile.dart
│   ├── domain/repositories/auth_repository.dart
│   ├── domain/repositories/user_repository.dart
│   ├── presentation/view_models/login_view_model.dart
│   ├── presentation/view_models/session_view_model.dart
│   ├── presentation/views/login_view.dart
│   └── presentation/views/session_view.dart
└── features/dashboard/presentation/
    ├── view_models/dashboard_view_model.dart
    ├── views/administrator_dashboard_view.dart
    └── views/optician_dashboard_view.dart
~~~

### Función de los grupos

- `main.dart`: inicia Flutter, Firebase y dependencias.
- `oculist_app.dart`: configura tema, rutas y repositorios.
- `app_router.dart`: controla rutas, sesión y roles.
- `startup`: verifica la sesión inicial.
- `authentication/data`: comunicación con Firebase.
- `authentication/domain`: modelos, contratos y excepciones.
- `authentication/presentation`: pantallas y lógica de sesión.
- `dashboard`: paneles del óptico y administrador.

### Configuración y pruebas utilizadas

~~~text
pubspec.yaml
pubspec.lock
firebase.json
android/app/google-services.json
android/app/build.gradle.kts
android/settings.gradle.kts
lib/firebase_options.dart
analysis_options.yaml
test/widget_test.dart
~~~

- `pubspec.yaml`: Firebase, Provider y GoRouter.
- archivos Firebase y Gradle: conexión con Firebase en Android.
- `widget_test.dart`: pruebas de las pantallas iniciales.


## Resultado del sprint

El acceso al sistema está controlado. Cada usuario activo entra al panel correspondiente y las rutas privadas no quedan disponibles sin iniciar sesión.

---

# Sprint 2: Gestión de clientes

## Objetivo

Registrar y administrar la información básica de los clientes de la óptica.

## Funciones principales

- Registrar clientes.
- Listar clientes activos.
- Buscar por nombre o teléfono.
- Consultar el detalle de un cliente.
- Editar datos.
- Desactivar clientes sin eliminarlos definitivamente.
- Permitir acceso tanto al óptico como al administrador.

## Datos principales del cliente

- Nombres.
- Apellidos.
- Teléfono.
- Documento de identidad opcional.
- Fecha de registro.
- Estado activo o inactivo.

## Casos de uso sencillos

### Registrar cliente

1. El usuario abre “Registrar cliente”.
2. Completa los datos obligatorios.
3. El sistema valida que los datos sean correctos.
4. Firestore crea el documento en la colección `clientes`.

### Buscar cliente

1. El usuario abre la lista de clientes.
2. Escribe un nombre o teléfono.
3. La lista muestra las coincidencias.

### Editar cliente

1. Se abre el detalle del cliente.
2. Se selecciona “Editar cliente”.
3. Se modifican los datos.
4. Firestore actualiza el registro.

### Desactivar cliente

1. El usuario confirma la desactivación.
2. El campo `activo` cambia a `false`.
3. El registro se conserva, pero deja de aparecer en la lista activa.

## Carpetas y archivos importantes

```text
lib/features/clients/
├── data/
│   ├── repositories/firestore_client_repository.dart
│   └── services/firestore_client_service.dart
├── domain/
│   ├── exceptions/client_exception.dart
│   ├── models/client.dart
│   └── repositories/client_repository.dart
└── presentation/
    ├── view_models/register_client_view_model.dart
    ├── view_models/client_list_view_model.dart
    ├── view_models/client_detail_view_model.dart
    ├── view_models/edit_client_view_model.dart
    ├── views/register_client_view.dart
    ├── views/client_list_view.dart
    ├── views/client_detail_view.dart
    └── views/edit_client_view.dart

test/features/clients/client_view_models_test.dart
```

## Tecnologías utilizadas

- Cloud Firestore para almacenar clientes.
- Provider y ChangeNotifier para manejar estados.
- GoRouter para navegar entre registro, lista, detalle y edición.

## Inventario completo de carpetas y archivos del Sprint 2

### Módulo completo de clientes

~~~text
lib/features/clients/
├── data/repositories/firestore_client_repository.dart
├── data/services/firestore_client_service.dart
├── domain/exceptions/client_exception.dart
├── domain/models/client.dart
├── domain/repositories/client_repository.dart
├── presentation/view_models/register_client_view_model.dart
├── presentation/view_models/client_list_view_model.dart
├── presentation/view_models/client_detail_view_model.dart
├── presentation/view_models/edit_client_view_model.dart
├── presentation/views/register_client_view.dart
├── presentation/views/client_list_view.dart
├── presentation/views/client_detail_view.dart
└── presentation/views/edit_client_view.dart
~~~

### Función de los grupos

- `data`: operaciones en Firestore, validación y conversión.
- `domain`: modelo, contrato y excepciones del cliente.
- `views`: registro, lista, detalle y edición.
- `view_models`: lógica y estado de cada pantalla.

### Archivos compartidos modificados

~~~text
lib/main.dart
lib/app/oculist_app.dart
lib/app/router/app_router.dart
lib/features/dashboard/presentation/views/optician_dashboard_view.dart
test/widget_test.dart
test/features/clients/client_view_models_test.dart
~~~

- aplicación: registró el repositorio.
- enrutador: añadió las cuatro rutas de clientes.
- panel: añadió el acceso al módulo.
- pruebas: validación, registro, búsqueda y desactivación.

### Recurso de Firebase

~~~text
Colección: clientes
Campos: nombres, apellidos, telefono, documentoIdentidad,
fechaRegistro y activo
~~~


## Resultado del sprint

El sistema permite administrar clientes desde ambos roles autorizados y conserva los registros desactivados.

---

# Sprint 3: Gestión del catálogo de monturas

## Objetivo

Crear un catálogo de monturas que posteriormente pueda utilizarse para las recomendaciones faciales.

## Funciones principales

- Registrar monturas.
- Seleccionar una imagen desde el dispositivo.
- Guardar la imagen en Firebase Storage.
- Guardar los datos en Firestore.
- Listar y buscar monturas.
- Mostrar el detalle con su imagen.
- Editar la información y reemplazar la imagen.
- Cambiar la disponibilidad.
- Desactivar una montura.
- Restringir el registro y edición al administrador.

## Datos principales de una montura

- Código.
- Marca.
- Modelo.
- Color.
- Forma.
- Material.
- Talla.
- URL de la imagen.
- Disponibilidad.
- Estado.
- Fecha de registro.

## Casos de uso sencillos

### Registrar montura

1. El administrador completa el formulario.
2. Selecciona una fotografía de la montura.
3. La imagen se sube a Firebase Storage.
4. Los datos y la URL se guardan en la colección `monturas`.

### Consultar catálogo

1. El usuario abre “Monturas”.
2. El sistema consulta las monturas activas.
3. Puede buscar por código, marca o modelo.
4. Al seleccionar una, se abre su detalle.

### Actualizar disponibilidad

1. El administrador abre el detalle.
2. Cambia la disponibilidad.
3. Firestore actualiza el campo `disponible`.
4. Una montura no disponible no se prioriza para recomendaciones.

## Carpetas y archivos importantes

```text
lib/features/frames/
├── data/
│   ├── repositories/firestore_frame_repository.dart
│   ├── services/firestore_frame_service.dart
│   └── services/frame_storage_service.dart
├── domain/
│   ├── exceptions/frame_exception.dart
│   ├── models/frame.dart
│   └── repositories/frame_repository.dart
└── presentation/
    ├── view_models/register_frame_view_model.dart
    ├── view_models/frame_list_view_model.dart
    ├── view_models/frame_detail_view_model.dart
    ├── view_models/edit_frame_view_model.dart
    ├── views/register_frame_view.dart
    ├── views/frame_list_view.dart
    ├── views/frame_detail_view.dart
    └── views/edit_frame_view.dart
```

## Tecnologías utilizadas

- Cloud Firestore: datos del catálogo.
- Firebase Storage: imágenes de las monturas.
- Image Picker: selección de imágenes del dispositivo.

## Recomendación para las imágenes

Las monturas deben fotografiarse de frente y preferiblemente guardarse como PNG con fondo transparente. Esto mejora el resultado de la prueba virtual.

## Inventario completo de carpetas y archivos del Sprint 3

### Módulo completo de monturas

~~~text
lib/features/frames/
├── data/repositories/firestore_frame_repository.dart
├── data/services/firestore_frame_service.dart
├── data/services/frame_storage_service.dart
├── domain/exceptions/frame_exception.dart
├── domain/models/frame.dart
├── domain/repositories/frame_repository.dart
├── presentation/view_models/register_frame_view_model.dart
├── presentation/view_models/frame_list_view_model.dart
├── presentation/view_models/frame_detail_view_model.dart
├── presentation/view_models/edit_frame_view_model.dart
├── presentation/views/register_frame_view.dart
├── presentation/views/frame_list_view.dart
├── presentation/views/frame_detail_view.dart
└── presentation/views/edit_frame_view.dart
~~~

### Función de los grupos

- `data/services`: Firestore e imágenes de Firebase Storage.
- `data/repositories`: coordina datos, imágenes y errores.
- `domain`: modelo, contrato y excepciones de monturas.
- `views`: registro, catálogo, detalle y edición.
- `view_models`: lógica, validación, disponibilidad y permisos.

### Archivos compartidos y configuración modificados

~~~text
lib/main.dart
lib/app/oculist_app.dart
lib/app/router/app_router.dart
lib/core/theme/app_theme.dart
lib/core/widgets/app_branding.dart
lib/features/authentication/data/repositories/firestore_user_repository.dart
lib/features/dashboard/presentation/view_models/dashboard_view_model.dart
lib/features/dashboard/presentation/views/administrator_dashboard_view.dart
lib/features/dashboard/presentation/views/optician_dashboard_view.dart
lib/features/dashboard/presentation/widgets/dashboard_home.dart
lib/firebase_options.dart
pubspec.yaml
pubspec.lock
test/widget_test.dart
~~~

- enrutador: rutas del catálogo y permisos administrativos.
- dashboard: accesos al catálogo para ambos roles.
- tema y branding: diseño visual común.
- `pubspec.yaml`: Firebase Storage e Image Picker.
- pruebas: repositorios y rutas del catálogo.

### Recursos de Firebase

~~~text
Firestore: colección monturas
Storage: imágenes del catálogo
Campos: codigo, marca, modelo, color, forma, material, talla,
imagenUrl, disponible, activo y fechaRegistro
~~~


## Resultado del sprint

Existe un catálogo administrable que proporciona los datos y las imágenes utilizados por el módulo de recomendación.

---

# Sprint 4: Captura facial, recomendación y prueba virtual

## Objetivo

Analizar el rostro de un cliente, recomendar como máximo tres monturas del catálogo y mostrar cómo se verían sobre su fotografía.

## Funciones principales

- Abrir la cámara frontal.
- Tomar una fotografía facial.
- Validar rostro, posición, iluminación y desenfoque.
- Detectar los ojos, contornos y orientación de la cabeza.
- Clasificar la forma del rostro.
- Guardar la fotografía y el análisis.
- Ordenar monturas compatibles.
- Mostrar un máximo de tres recomendaciones.
- Superponer cada montura sobre el rostro.
- Eliminar visualmente fondos blancos de las monturas.

## Tipos de rostro utilizados

- Ovalado.
- Redondo.
- Cuadrado.
- Alargado.
- Corazón.

## Caso de uso principal completo

1. El usuario abre el detalle de un cliente.
2. Presiona “Capturar fotografía facial” o “Reemplazar fotografía facial”.
3. La aplicación abre la cámara frontal.
4. El cliente centra el rostro y mira de frente.
5. ML Kit comprueba que exista un solo rostro.
6. El sistema revisa tamaño, posición, inclinación, luz y nitidez.
7. Detecta la forma del rostro y la posición de ambos ojos.
8. El usuario confirma la fotografía.
9. Firebase Storage guarda la foto facial.
10. Firestore guarda la URL, el tipo de rostro, la geometría de los ojos y la fecha.
11. El sistema consulta monturas activas y disponibles.
12. Las ordena según su compatibilidad con la forma del rostro.
13. Presenta como máximo las tres mejores.
14. Combina la foto del usuario con cada montura.

## Ejemplo de recomendación

- Rostro redondo: prioriza monturas rectangulares o cuadradas.
- Rostro cuadrado: prioriza monturas redondas, ovaladas o aviador.
- Rostro ovalado: admite varias formas y prioriza opciones equilibradas.
- Rostro alargado: prioriza monturas redondas, ovaladas o grandes.
- Rostro corazón: prioriza monturas ovaladas, redondas o aviador.

## Validaciones de la fotografía

El sistema puede mostrar mensajes como:

- “Acérquese un poco a la cámara”.
- “Aléjese para que el rostro quede completo”.
- “Mire al frente”.
- “Suba o baje un poco la cabeza”.
- “La fotografía está muy oscura”.
- “La fotografía está demasiado borrosa”.
- “No se localizaron ambos ojos”.

## Carpetas y archivos importantes

```text
lib/features/face_capture/
├── data/services/face_validation_service.dart
├── domain/models/face_capture_result.dart
├── domain/models/face_validation_result.dart
├── domain/models/face_shape.dart
├── domain/models/face_geometry.dart
└── presentation/views/face_capture_view.dart

lib/features/virtual_try_on/
└── presentation/
    ├── view_models/try_on_selection_view_model.dart
    ├── views/try_on_selection_view.dart
    └── widgets/virtual_frame_preview.dart

lib/features/clients/data/services/client_photo_storage_service.dart
firestore.rules
storage.rules
test/features/virtual_try_on/try_on_selection_view_model_test.dart
```

## Tecnologías utilizadas

- Plugin `camera`: acceso a la cámara frontal.
- Google ML Kit Face Detection: rostro, ojos, contornos y posición.
- Firebase Storage: fotografía facial.
- Cloud Firestore: resultado del análisis.
- Librería `image`: vuelve transparentes los fondos blancos claros de las monturas durante la visualización.

## Aclaración importante

La aplicación no genera una cara nueva mediante inteligencia artificial. Utiliza la fotografía real del cliente y coloca encima la imagen de una montura del catálogo. La imagen original de la montura no se modifica en Firebase; la eliminación del fondo se realiza temporalmente al mostrar la recomendación.

## Inventario completo de carpetas y archivos del Sprint 4

### Captura facial

~~~text
lib/features/face_capture/
├── data/services/face_validation_service.dart
├── domain/models/face_capture_result.dart
├── domain/models/face_validation_result.dart
├── domain/models/face_shape.dart
├── domain/models/face_geometry.dart
└── presentation/views/face_capture_view.dart
~~~

### Recomendación y prueba virtual

~~~text
lib/features/virtual_try_on/
├── presentation/view_models/try_on_selection_view_model.dart
├── presentation/views/try_on_selection_view.dart
└── presentation/widgets/virtual_frame_preview.dart
~~~

### Archivos de clientes ampliados

~~~text
lib/features/clients/data/repositories/firestore_client_repository.dart
lib/features/clients/data/services/firestore_client_service.dart
lib/features/clients/data/services/client_photo_storage_service.dart
lib/features/clients/domain/models/client.dart
lib/features/clients/domain/repositories/client_repository.dart
lib/features/clients/presentation/view_models/client_detail_view_model.dart
lib/features/clients/presentation/views/client_detail_view.dart
~~~

### Función de los grupos

- `face_capture_view.dart`: cámara, captura, confirmación y repetición.
- `face_validation_service.dart`: ML Kit, posición, luz y nitidez.
- modelos faciales: resultado, forma del rostro y coordenadas de ojos.
- `try_on_selection_view_model.dart`: ordena y limita a tres monturas.
- `try_on_selection_view.dart`: presenta las recomendaciones.
- `virtual_frame_preview.dart`: superpone, escala, inclina y limpia el fondo.
- archivos de clientes: suben la foto y guardan el análisis.

### Configuración, permisos, reglas y pruebas

~~~text
lib/main.dart
lib/app/router/app_router.dart
android/app/src/main/AndroidManifest.xml
ios/Runner/Info.plist
firebase.json
firestore.rules
storage.rules
pubspec.yaml
pubspec.lock
test/widget_test.dart
test/features/clients/client_view_models_test.dart
test/features/virtual_try_on/try_on_selection_view_model_test.dart
~~~

- manifiestos: permisos de cámara.
- reglas: permisos para foto y geometría facial.
- `pubspec.yaml`: Camera, ML Kit e Image.
- pruebas: clientes, ranking de monturas y pantalla inicial.

### Campos agregados al cliente

~~~text
fotoFacialUrl
tipoRostro
geometriaFacial
fechaAnalisisFacial
~~~


## Resultado y validación

- Análisis estático de Flutter sin errores.
- Diez pruebas automáticas aprobadas al finalizar el desarrollo.
- Reglas de Firestore publicadas.
- Falta una prueba práctica final con al menos tres monturas diferentes y fotografías PNG transparentes.

---

# Sprint 5: Historial de recomendaciones y selección final

## Estado

Pendiente de implementación.

## Objetivo

Guardar cada análisis y las monturas recomendadas para consultar posteriormente qué opciones recibió un cliente y cuál eligió.

## Funciones propuestas

- Crear un historial por cliente.
- Guardar la fecha de la recomendación.
- Guardar el tipo de rostro detectado en ese momento.
- Guardar las tres monturas sugeridas.
- Permitir marcar una montura como seleccionada.
- Consultar el detalle de una recomendación anterior.
- Evitar perder resultados cuando se toma una fotografía nueva.

## Casos de uso propuestos

### Guardar recomendación

1. El sistema termina el análisis facial.
2. Obtiene hasta tres monturas.
3. Crea un documento en `recomendaciones`.
4. Guarda el cliente, fecha, tipo de rostro y monturas sugeridas.

### Seleccionar una montura

1. El cliente compara las recomendaciones.
2. El usuario presiona “Seleccionar esta montura”.
3. El historial guarda la montura elegida.
4. El catálogo puede actualizar su disponibilidad si el proceso de negocio lo requiere.

### Consultar historial

1. Se abre el detalle del cliente.
2. Se selecciona “Historial de recomendaciones”.
3. Aparecen los análisis ordenados por fecha.
4. Se abre un resultado para consultar sus monturas.

## Estructura propuesta

```text
lib/features/recommendations/
├── data/
│   ├── repositories/firestore_recommendation_repository.dart
│   └── services/firestore_recommendation_service.dart
├── domain/
│   ├── models/recommendation.dart
│   └── repositories/recommendation_repository.dart
└── presentation/
    ├── view_models/recommendation_history_view_model.dart
    ├── view_models/recommendation_detail_view_model.dart
    ├── views/recommendation_history_view.dart
    └── views/recommendation_detail_view.dart

test/features/recommendations/
```

## Datos propuestos para Firestore

Colección `recomendaciones`:

- `clienteId`.
- `fecha`.
- `tipoRostro`.
- `fotoFacialUrl`.
- `monturasRecomendadas`.
- `monturaSeleccionadaId`, opcional.
- `usuarioResponsableId`.

## Reglas que deberían actualizarse

- Permitir que óptico y administrador creen y consulten recomendaciones.
- Validar los campos obligatorios.
- Impedir eliminaciones accidentales.
- Comprobar que los identificadores y fechas sean válidos.

## Inventario completo propuesto para el Sprint 5

### Archivos nuevos

~~~text
lib/features/recommendations/
├── data/repositories/firestore_recommendation_repository.dart
├── data/services/firestore_recommendation_service.dart
├── domain/exceptions/recommendation_exception.dart
├── domain/models/recommendation.dart
├── domain/repositories/recommendation_repository.dart
├── presentation/view_models/recommendation_history_view_model.dart
├── presentation/view_models/recommendation_detail_view_model.dart
├── presentation/views/recommendation_history_view.dart
└── presentation/views/recommendation_detail_view.dart

test/features/recommendations/
├── recommendation_view_models_test.dart
└── recommendation_repository_test.dart
~~~

### Archivos existentes que deberán modificarse

~~~text
lib/main.dart
lib/app/oculist_app.dart
lib/app/router/app_router.dart
lib/features/clients/presentation/views/client_detail_view.dart
lib/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart
lib/features/virtual_try_on/presentation/views/try_on_selection_view.dart
firestore.rules
test/widget_test.dart
~~~

- aplicación: registrará el nuevo repositorio.
- enrutador: rutas del historial y detalle.
- detalle del cliente: botón para abrir el historial.
- prueba virtual: guardar resultado y montura elegida.
- reglas: proteger la colección `recomendaciones`.

### Recurso que se creará

~~~text
Colección Firestore: recomendaciones
Campos: clienteId, fecha, tipoRostro, fotoFacialUrl,
monturasRecomendadas, monturaSeleccionadaId y usuarioResponsableId
~~~


## Criterio para completar el sprint

El sprint termina cuando una recomendación puede guardarse, consultarse desde el cliente y marcar una montura como elegida, con pruebas automáticas aprobadas.

---

# Sprint 6: Reportes, calidad y preparación de entrega

## Estado

Pendiente de implementación.

## Objetivo

Preparar el sistema para su presentación final, agregar información útil para el administrador y comprobar que los módulos funcionen de manera integrada.

## Funciones propuestas

- Panel de estadísticas para el administrador.
- Cantidad de clientes activos.
- Cantidad de monturas activas y disponibles.
- Cantidad de análisis o recomendaciones realizadas.
- Formas de rostro más detectadas.
- Monturas más seleccionadas.
- Filtros básicos por fecha.
- Estados de carga, mensajes y manejo de errores mejorados.
- Revisión visual en diferentes tamaños de pantalla.
- Pruebas integrales del flujo completo.
- Documentación técnica y manual de usuario.

## Casos de uso propuestos

### Consultar resumen administrativo

1. El administrador abre su panel.
2. El sistema consulta clientes, monturas y recomendaciones.
3. Muestra tarjetas con cantidades y resultados principales.

### Consultar monturas preferidas

1. Se consultan las recomendaciones con una montura seleccionada.
2. Se agrupan los resultados por montura.
3. Se muestran las más elegidas.

### Ejecutar prueba integral

1. Iniciar sesión con ambos roles.
2. Registrar y editar un cliente.
3. Registrar al menos tres monturas con imágenes.
4. Capturar una fotografía válida e inválida.
5. Verificar las tres recomendaciones.
6. Guardar y consultar el historial.
7. Cerrar sesión y comprobar la protección de rutas.

## Estructura propuesta

```text
lib/features/reports/
├── data/
├── domain/
└── presentation/
    ├── view_models/reports_view_model.dart
    └── views/reports_view.dart

test/features/reports/
test/integration/
docs/MANUAL_DE_USUARIO.md
docs/DOCUMENTACION_TECNICA.md
```

También podrían ampliarse:

```text
lib/features/dashboard/
test/widget_test.dart
firestore.rules
```

## Pruebas finales recomendadas

- Inicio de sesión correcto e incorrecto.
- Permisos diferentes para óptico y administrador.
- Registro, búsqueda, edición y desactivación de clientes.
- Registro, edición y disponibilidad de monturas.
- Subida y visualización de imágenes.
- Captura con buena y mala iluminación.
- Rechazo de fotografías borrosas o sin rostro.
- Recomendación con 1, 2, 3 y más monturas disponibles.
- Ajuste visual con fondos transparentes y blancos.
- Historial de recomendaciones.
- Comportamiento sin conexión o ante errores de Firebase.

## Documentos finales sugeridos

- Manual de usuario.
- Manual técnico.
- Diagrama de arquitectura.
- Modelo de datos de Firestore.
- Casos de uso.
- Resultados de pruebas.
- Capturas de pantalla de cada módulo.
- Lista de APIs, servicios y librerías utilizadas.

## Inventario completo propuesto para el Sprint 6

### Archivos nuevos de reportes

~~~text
lib/features/reports/
├── data/repositories/firestore_report_repository.dart
├── data/services/firestore_report_service.dart
├── domain/models/report_summary.dart
├── domain/repositories/report_repository.dart
├── presentation/view_models/reports_view_model.dart
├── presentation/views/reports_view.dart
├── presentation/widgets/report_summary_card.dart
└── presentation/widgets/report_chart.dart

test/features/reports/
├── reports_view_model_test.dart
└── reports_view_test.dart
~~~

### Archivos existentes que deberán modificarse

~~~text
lib/main.dart
lib/app/oculist_app.dart
lib/app/router/app_router.dart
lib/core/theme/app_theme.dart
lib/core/widgets/app_branding.dart
lib/features/dashboard/presentation/views/administrator_dashboard_view.dart
lib/features/dashboard/presentation/widgets/dashboard_home.dart
firestore.rules
pubspec.yaml
test/widget_test.dart
~~~

### Documentos y pruebas integrales que deberán crearse

~~~text
docs/MANUAL_DE_USUARIO.md
docs/DOCUMENTACION_TECNICA.md
docs/MODELO_DE_DATOS.md
docs/CASOS_DE_USO.md
docs/RESULTADOS_DE_PRUEBAS.md
test/integration/authentication_flow_test.dart
test/integration/client_flow_test.dart
test/integration/recommendation_flow_test.dart
~~~

- `reports`: consulta, agrupa y presenta estadísticas.
- panel administrativo: acceso a los reportes.
- enrutador: ruta protegida de reportes.
- pruebas integrales: comprueban flujos completos.
- documentos: material de uso, mantenimiento y defensa.


## Criterio para completar el sprint

El sistema debe superar las pruebas funcionales, mostrar información administrativa útil y contar con documentación suficiente para instalarlo, utilizarlo y defenderlo en la presentación del proyecto.

---

# 3. Resumen de APIs, servicios y herramientas

| Elemento | Clasificación | Uso en OCULIST |
|---|---|---|
| Firebase Authentication | Servicio consumido mediante API | Inicio y cierre de sesión |
| Cloud Firestore | Servicio consumido mediante API | Usuarios, clientes, monturas y análisis |
| Firebase Storage | Servicio consumido mediante API | Fotografías faciales y monturas |
| Google ML Kit Face Detection | SDK/API | Detección y análisis del rostro |
| Cámara de Android/iOS | API del dispositivo | Captura con cámara frontal |
| `image_picker` | Plugin | Selección de imágenes |
| `image` | Librería local | Limpieza temporal del fondo blanco |
| Provider | Librería | Gestión de estado |
| GoRouter | Librería | Navegación y protección de rutas |

# 4. Flujo general del sistema

```text
Inicio de sesión
      ↓
Panel según el rol
      ↓
Gestión de clientes y catálogo
      ↓
Captura y validación facial
      ↓
Clasificación del rostro
      ↓
Selección de hasta 3 monturas
      ↓
Prueba virtual
      ↓
Historial y selección (Sprint 5)
      ↓
Reportes y cierre del proyecto (Sprint 6)
```

# 5. Qué falta actualmente

1. Registrar al menos tres monturas reales y comprobar la prueba virtual.
2. Ajustar tamaño o posición si alguna imagen del catálogo tiene proporciones diferentes.
3. Implementar el historial de recomendaciones del Sprint 5.
4. Implementar reportes y pruebas finales del Sprint 6.
5. Preparar manuales, capturas y resultados para la presentación.

# 6. Recomendación para estudiar

Estudia cada sprint respondiendo estas cinco preguntas:

1. ¿Qué problema resuelve?
2. ¿Quién utiliza la función?
3. ¿Qué datos entran y qué resultado sale?
4. ¿Qué archivo controla la pantalla, la lógica y Firebase?
5. ¿Qué sucede cuando hay un error?

Si puedes explicar esas cinco preguntas para cada sprint, podrás defender con claridad cómo funciona tu sistema.
