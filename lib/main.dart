// lib/main.dart
//
// Punto de entrada de la aplicación.
// Configura el MaterialApp con Material Design 3, tema personalizado
// y locale en español.

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

/// Punto de entrada principal de la app.
void main() async {
  // Necesario para inicializar plugins antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa datos de localización en español para formateo de fechas
  await initializeDateFormatting('es', null);

  runApp(const TodoApp());
}

/// Widget raíz de la aplicación.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Tareas',
      debugShowCheckedModeBanner: false,

      // ── Tema claro con Material Design 3 ──
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6CF7),
          brightness: Brightness.light,
        ),
        // Estilo de tarjetas consistente
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        // Campos de texto con bordes redondeados
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        // AppBar sin elevación para look moderno
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),

      // ── Tema oscuro (soporte automático) ──
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6CF7),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        appBarTheme: const AppBarTheme(elevation: 0),
      ),

      themeMode: ThemeMode.system, // respeta la preferencia del sistema

      home: const HomeScreen(),
    );
  }
}
