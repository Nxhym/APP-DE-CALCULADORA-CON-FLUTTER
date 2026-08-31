# 📱 Mi Calculadora - Flutter Multiplataforma

Aplicación móvil, web y de escritorio para cálculos matemáticos con interfaz moderna basada en **Material Design 3**, arquitectura declarativa con **Flutter Riverpod**, enrutamiento desacoplado con **GoRouter**, soporte de diseño adaptativo (**Responsive Layout**) y persistencia local de estado con **SharedPreferences**.

---

## 🚀 Características Principales

- **Diseño Adaptativo (Responsive Breakpoints)**:
  - **Móvil (< 600px)**: Interfaz de una sola columna con barra de navegación inferior (`NavigationBar`) para alternar entre el teclado de la calculadora y el historial de operaciones.
  - **Tablet / Escritorio (≥ 600px)**: Disposición en dos columnas (`Row` con `Expanded` y `VerticalDivider`) que muestra la calculadora y la bitácora de historial simultáneamente en pantalla dividida, junto a un `NavigationRail` lateral.
- **Gestión de Estado Unidireccional (Riverpod)**:
  - Manejo desacoplado e inmutable del estado mediante `StateNotifierProvider` y `CalculatorState`.
  - Control de buffer, operando anterior, operador activo, flags de limpieza condicional (`shouldClear`) y lista inmutable de operaciones.
- **Motor de Cálculo y Aritmética Robusta**:
  - Operaciones aritméticas fundamentales: Suma (`+`), Resta (`-`), Multiplicación (`x`) y División (`/`).
  - Detección y manejo seguro de división por cero e indeterminaciones numéricas con despliegue de estado de `Error`.
  - Soporte de encadenamiento continuo de operaciones (ej. `5 + 5 + 5 =`).
  - Formateo dinámico de precisión: supresión de ceros redundantes a la derecha y presentación limpia de enteros.
  - Soporte para alternancia de signo (`+/-`), punto decimal único (`.`), borrado unitario con retroceso (`backspace`) y reseteo completo (`AC`).
  - Lógica de porcentaje contextual (`%`): cálculo proporcional relativo al valor base acumulado o conversión decimal directa.
- **Persistencia Local de Historial y Preferencias**:
  - Almacenamiento local mediante `SharedPreferences` serializando objetos `HistoryItem` a JSON.
  - Carga y recuperación automática del historial de cálculos entre sesiones de la aplicación.
  - Opción de vaciado integral del historial en disco.
- **Tema Dinámico Claro / Oscuro (Material Design 3)**:
  - Paleta tonal coherente generada dinámicamente mediante `colorSchemeSeed: Colors.indigo`.
  - `ThemeProvider` persistente que respeta o conmuta entre modos `Light`, `Dark` o del sistema operativo.

---

## 🏗️ Arquitectura y Estructura del Proyecto

El código fuente sigue una separación estricta de responsabilidades bajo la carpeta `lib/`:

```text
mi_calculadora/
├── lib/
│   ├── config/
│   │   ├── router.dart              # Configuración de GoRouter con ShellRoute y llaves de navegación
│   │   └── theme.dart               # Definición de temas claro y oscuro basados en Material 3
│   ├── models/
│   │   └── history_item.dart        # Modelo inmutable de historial y serialización JSON
│   ├── providers/
│   │   ├── calculator_provider.dart # Lógica de negocio, máquina de estados y persistencia
│   │   └── theme_provider.dart      # Notifier para control de temas y persistencia SharedPreferences
│   ├── screens/
│   │   ├── calculator_screen.dart   # Pantalla principal con layout responsivo
│   │   ├── history_screen.dart      # Vista de lista de operaciones pasadas y opción de borrado
│   │   └── shell_screen.dart        # Contenedor con barra de navegación adaptativa (BottomNav / NavRail)
│   ├── widgets/
│   │   ├── calculator_button.dart   # Botón reutilizable con estilos Material 3, InkWell y semántica accesible
│   │   └── responsive_layout.dart   # LayoutBuilder con breakpoints para móvil, tablet y escritorio
│   └── main.dart                    # Punto de entrada de la aplicación con ProviderScope
├── test/
│   └── widget_test.dart             # Pruebas unitarias y de widgets
├── pubspec.yaml                     # Manifiesto de dependencias y configuración de Flutter
└── README.md                        # Documentación técnica del proyecto
