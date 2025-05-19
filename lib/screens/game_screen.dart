import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import '../models/user.dart';
import '../models/game_state.dart';
import '../models/questions/question.dart';
import '../models/questions/question_repository.dart';
import '../models/game_options.dart';
import 'user_profile_screen.dart';

class GameScreen extends StatefulWidget {
  final User user1;
  final User user2;
  final int bullets;

  const GameScreen({
    Key? key,
    required this.user1,
    required this.user2,
    required this.bullets,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shootingAnimation;

  late GameState gameState;
  Question? currentQuestion;
  bool showingQuestion = false;
  int? selectedAnswer;

  // Resultado de la pregunta
  bool? questionAnsweredCorrectly;

  // Reproducción de audio
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer shootAudioPlayer =
      AudioPlayer(); // Reproductor específico para disparos
  final GameOptions gameOptions = GameOptions();

  @override
  void initState() {
    super.initState();

    // Asegurar que ambos jugadores tengan exactamente 2 vidas al iniciar
    widget.user1.lives = 2;
    widget.user2.lives = 2;
    
    // Inicializar el estado del juego
    gameState = GameState(user1: widget.user1, user2: widget.user2);

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _shootingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Inicializar el tambor con el número de balas seleccionado
    gameState.initChamber(widget.bullets);
  }

  // Función para reproducir el sonido de respuesta correcta
  Future<void> _playCorrectAnswerSound() async {
    try {
      await audioPlayer.play(AssetSource('audio/audio2.mp3'));
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  // Función para reproducir el sonido de disparo según el arma seleccionada
  Future<void> _playShootSound() async {
    try {
      final String soundPath = gameOptions.getSelectedWeaponSound();
      await shootAudioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('Error al reproducir sonido de disparo: $e');
    }
  }

  void girarRevolver() {
    if (!gameState.isSpinning && !gameState.isShooting && !showingQuestion) {
      setState(() {
        gameState.isSpinning = true;
      });

      // Girar el tambor y el cañón
      gameState.spin();

      // Calcular el ángulo de rotación para el tambor
      double vueltasCompletas = 3.0; // 3 vueltas completas

      // Ángulo final del cañón (0 o 0.5 vueltas)
      double canonFinalAngle = gameState.getCanonAngle();

      // El ángulo final debe ser 0 (arriba) o 0.5 (abajo) vueltas
      // Añadimos las vueltas completas al ángulo final del cañón
      double targetAngle = vueltasCompletas + canonFinalAngle;

      _controller.reset();
      _controller.duration = Duration(seconds: 3);

      _rotationAnimation = Tween<double>(begin: 0, end: targetAngle).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.forward().then((_) {
        setState(() {
          gameState.isSpinning = false;
          // Mostrar pregunta después de girar al usuario que tiene el cañón apuntando
          mostrarPregunta();
        });
      });
    }
  }

  void mostrarPregunta() {
    // Obtener una pregunta aleatoria
    currentQuestion = QuestionRepository.getRandomQuestion();

    setState(() {
      showingQuestion = true;
      selectedAnswer = null;
      questionAnsweredCorrectly = null;
    });

    // Obtener el usuario al que apunta el cañón
    User targetUser = gameState.getTargetUser();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.brown[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.brown[700]!, width: 3),
          ),
          title: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.brown[700]!, width: 2)),
              gradient: LinearGradient(
                colors: [Colors.brown[800]!, Colors.brown[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              'Pregunta para ${targetUser.name}',
              style: TextStyle(
                color: Colors.amber[100],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.brown[800]!, Colors.brown[900]!],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.brown[800],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.brown[600]!, width: 2),
                    ),
                    child: Text(
                      currentQuestion!.text,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.amber[100],
                      ),
                    ),
                  ),
                  ...List.generate(4, (index) {
                    String option = String.fromCharCode(65 + index); // A, B, C, D
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: selectedAnswer == index ? Colors.brown[600] : Colors.brown[700],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown[500]!, width: 1),
                      ),
                      child: RadioListTile<int>(
                        title: Text(
                          '$option. ${currentQuestion!.options[index]}',
                          style: TextStyle(
                            color: Colors.amber[100],
                          ),
                        ),
                        value: index,
                        groupValue: selectedAnswer,
                        onChanged: questionAnsweredCorrectly != null
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedAnswer = value;
                                });
                              },
                        activeColor: Colors.amber,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.brown[700]!, width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (questionAnsweredCorrectly == null)
                    ElevatedButton(
                      onPressed: selectedAnswer != null
                          ? () {
                              bool isCorrect = currentQuestion!.isCorrect(selectedAnswer!);
                              setDialogState(() {
                                questionAnsweredCorrectly = isCorrect;
                              });
                              if (isCorrect) {
                                _playCorrectAnswerSound();
                              } else {
                                // Mostrar alerta de respuesta incorrecta
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.red[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(color: Colors.red[700]!, width: 3),
                                    ),
                                    title: Text(
                                      '¡${targetUser.name}!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      'RESPUESTA INCORRECTA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          setState(() {
                                            showingQuestion = false;
                                          });
                                          dispararRevolver(targetUser: targetUser);
                                        },
                                        child: Text(
                                          'Aceptar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              Future.delayed(Duration(seconds: 1), () {
                                if (isCorrect) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    showingQuestion = false;
                                  });
                                  mostrarOpcionesDisparo(targetUser);
                                }
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[600],
                        foregroundColor: Colors.amber[100],
                      ),
                      child: Text('Responder'),
                    ),
                  if (questionAnsweredCorrectly != null)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          showingQuestion = false;
                        });
                        if (questionAnsweredCorrectly!) {
                          mostrarOpcionesDisparo(targetUser);
                        } else {
                          dispararRevolver(targetUser: targetUser);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.amber[100],
                      ),
                      child: Text('Continuar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void mostrarOpcionesDisparo(User targetUser) {
    User otherUser = targetUser == widget.user1 ? widget.user2 : widget.user1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.brown[700]!, width: 3),
        ),
        title: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.brown[700]!, width: 2)),
            gradient: LinearGradient(
              colors: [Colors.brown[800]!, Colors.brown[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Text(
            '¡Respuesta correcta!',
            style: TextStyle(
              color: Colors.amber[100],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.brown[800]!, Colors.brown[900]!],
              center: Alignment.center,
              radius: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${targetUser.name}, puedes elegir a quién disparar:',
                style: TextStyle(
                  color: Colors.amber[100],
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[700]!, Colors.orange[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[800]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    dispararRevolver(targetUser: targetUser);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'Disparar a mí mismo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[700]!, Colors.red[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[800]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    dispararRevolver(targetUser: otherUser);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'Disparar a ${otherUser.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dispararRevolver({required User targetUser}) {
    if (!gameState.isSpinning && !gameState.isShooting) {
      setState(() {
        gameState.isShooting = true;
      });

      // Simular el disparo
      _controller.reset();
      _controller.duration = Duration(milliseconds: 500);

      // Reproducir el sonido de disparo
      _playShootSound();

      _controller.forward().then((_) {
        // Verificar si hay una bala en la recámara
        bool hasBullet = gameState.shoot();

        setState(() {
          gameState.isShooting = false;

          if (hasBullet) {
            // Si hay bala, el usuario pierde una vida, pero no menos de 0
            if (targetUser.lives > 0) {
              targetUser.lives--;
            }

            // Verificar si el juego ha terminado
            if (targetUser.lives <= 0) {
              // Asegurar que las vidas no sean negativas
              targetUser.lives = 0;
              
              // El usuario ha perdido
              User winner =
                  targetUser == widget.user1 ? widget.user2 : widget.user1;
              winner.wins++;
              targetUser.losses++;

              // Mostrar mensaje de fin de juego
              mostrarFinJuego(winner);
            }
          }
        });
      });
    }
  }

  void mostrarFinJuego(User winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: gameOptions.isDarkMode ? Colors.grey[850] : Colors.brown[900],
            title: Text(
              '¡Fin del juego!',
              style: TextStyle(
                color: gameOptions.isDarkMode ? Colors.white : Colors.amber[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                  '¡${winner.name} ha ganado!',
                  style: TextStyle(
                    color: gameOptions.isDarkMode ? Colors.white : Colors.amber[900],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Estadísticas:',
                  style: TextStyle(
                    color: gameOptions.isDarkMode ? Colors.white : Colors.amber[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.user1.name}: ${widget.user1.wins} victorias, ${widget.user1.losses} derrotas',
                  style: TextStyle(
                    color: gameOptions.isDarkMode ? Colors.white : Colors.amber[900],
                  ),
                ),
                Text(
                  '${widget.user2.name}: ${widget.user2.wins} victorias, ${widget.user2.losses} derrotas',
                  style: TextStyle(
                    color: gameOptions.isDarkMode ? Colors.white : Colors.amber[900],
                  ),
                ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Volver al menú principal
                },
                child: Text(
                  'Volver al menú',
                  style: TextStyle(
                    color: gameOptions.isDarkMode 
                        ? Colors.lightBlueAccent 
                        : Colors.amber[900],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Reiniciar el juego
                  setState(() {
                    widget.user1.lives = 2;
                    widget.user2.lives = 2;
                    gameState = GameState(
                      user1: widget.user1,
                      user2: widget.user2,
                    );
                    gameState.initChamber(widget.bullets);
                  });
                },
                child: Text(
                  'Jugar de nuevo',
                  style: TextStyle(
                    color: gameOptions.isDarkMode ? null : Colors.brown[700],
                  ),
                ),
                style: gameOptions.isDarkMode 
                    ? null
                    : ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[600],
                      ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario al que apunta el cañón
    User targetUser = gameState.getTargetUser();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        elevation: 0,
        actions: [
          // Mantener los botones de perfil originales
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: widget.user1),
                ),
              );
            },
            tooltip: 'Perfil de ${widget.user1.name}',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: widget.user2),
                ),
              );
            },
            tooltip: 'Perfil de ${widget.user2.name}',
          ),
        ],
      ),
      // Aplicar el color de fondo según el modo oscuro
      backgroundColor: Colors.brown[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[800]!, Colors.brown[900]!],
          ),
          image: DecorationImage(
            image: AssetImage('assets/img/madera.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            // Tapete negro
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.brown[700]!,
                width: 3,
              ),
              // Patru00f3n sutil en el tapete
              backgroundBlendMode: BlendMode.overlay,
              gradient: RadialGradient(
                colors: [Colors.black54, Colors.black87],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tu00edtulo estilizado
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber[700]!, width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: Text(
                    'RULETA RUSA',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.amber[900]!,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
            // Vidas del Usuario 1
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user1.name}: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ...List.generate(2, (index) {
                  return Icon(
                    Icons.favorite,
                    color:
                        index < widget.user1.lives
                            ? widget.user1.heartColor
                            : Colors.grey,
                    size: 30,
                  );
                }),
              ],
            ),
            SizedBox(height: 10),
            // Vidas del Usuario 2
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user2.name}: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ...List.generate(2, (index) {
                  return Icon(
                    Icons.favorite,
                    color:
                        index < widget.user2.lives
                            ? widget.user2.heartColor
                            : Colors.grey,
                    size: 30,
                  );
                }),
              ],
            ),
            SizedBox(height: 40),
            // Revólver - Usando el arma seleccionada en opciones
            Stack(
              alignment: Alignment.center,
              children: [
                // Tambor del revólver
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Image.asset(
                    gameOptions.selectedWeapon, // Usamos el arma seleccionada
                    width: 200,
                    height: 200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Indicador de turno
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    targetUser == widget.user1
                        ? widget.user1.heartColor
                        : widget.user2.heartColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Turno de ${targetUser.name}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),
            // Botón para girar
            ElevatedButton(
              onPressed:
                  gameState.isSpinning ||
                          gameState.isShooting ||
                          showingQuestion
                      ? null
                      : girarRevolver,
              child: Text('Girar Tambor'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor:
                    gameOptions.isDarkMode ? Colors.blueGrey[700] : null,
              ),
            ),
            SizedBox(height: 30),
            // Contador de posición de las balas
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Posición de las balas:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(6, (index) {
                      // Verificar si hay una bala en esta posición
                      bool hasBullet = gameState.chamber.length > index && gameState.chamber[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: hasBullet ? Colors.red : Colors.transparent,
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: hasBullet ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Posición actual: ${gameState.currentChamberPosition + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    audioPlayer.dispose();
    shootAudioPlayer
        .dispose(); // Liberamos también el reproductor de sonidos de disparo
    super.dispose();
  }
}
