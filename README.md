# Ruleta Rusa - Juego Flutter

Un juego de Ruleta Rusa desarrollado con Flutter, que combina la emoción del juego clásico con un sistema de preguntas y respuestas.

## 📱 Características

- 🎮 Juego para 2 jugadores
- ❤️ Sistema de vidas (2 vidas por jugador)
- 🔫 Selección de número de balas (1-5)
- ❓ Sistema de preguntas y respuestas
- 🎵 Efectos de sonido y música de fondo
- 🌙 Modo oscuro/claro
- 📊 Sistema de estadísticas de jugadores

## 🚀 Requisitos Previos

- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- Git

## ⚙️ Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/yersonxz116/ruleta4.git
```
2. Navega al directorio del proyecto:
```bash
cd ruleta4
```
3. Instala las dependencias:
```bash
flutter pub get
```
4. Ejecuta el proyecto:
```bash
flutter run
```
## 🎮 Cómo Jugar
1. Inicia el juego presionando "JUGAR"
2. Ingresa los nombres de los dos jugadores
3. Selecciona el número de balas (1-5)
4. El revólver girará aleatoriamente
5. El jugador apuntado deberá responder una pregunta
6. Si responde correctamente:
   - Puede elegir a quién disparar
7. Si responde incorrectamente:
   - El disparo va directo hacia él
8. El juego continúa hasta que un jugador pierda todas sus vidas
## 🛠️ Tecnologías Utilizadas
- Flutter
- Dart
- AudioPlayers (para efectos de sonido)
- Provider (para gestión de estado)