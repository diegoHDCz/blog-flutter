import 'package:flutter/material.dart';

class AppPallet {
  // Light Mode - Extraído da imagem
  static const Color primaryLight = Color(0xFF15B6D6); // Azul/Verde gradiente (fundo)
  static const Color primaryLightAccent = Color(0xFFffd666); // Amarelo (emoji)
  static const Color textLightPrimary = Color(0xFFFFFFFF); // Branco (texto principal)
  static const Color textLightSecondary = Color(0xFFA1E9C5); // Tom mais claro de verde (subtítulo)
  static const Color backgroundColor = Color.fromARGB(255, 244, 251, 252); // Azul/Verde gradiente (fundo)
  
  // Dark Mode - Definido por você
  static const Color primaryDark = Color(0xFF121212); // Background Slate (Cinza escuro)
  static const Color primaryDarkAccent = Color(0xFFFFB74D); // Amarelo Terracota
  
  // Cor secundária para Dark Mode que combina (minha escolha)
  static const Color secondaryDark = Color(0xFF4DB6AC); // Um tom de verde-azulado mais suave que combina com o Slate e o Terracota
  
  // Texto Dark Mode
  static const Color textDarkPrimary = Color(0xFFE0E0E0); // Cinza claro (para evitar contraste excessivo)
  static const Color textDarkSecondary = Color(0xFF9E9E9E); // Cinza médio
  static const Color transparent = Colors.transparent;

  // Você pode adicionar outras cores como superfícies, erros, etc., se necessário.
}