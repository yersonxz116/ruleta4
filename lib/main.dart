import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/user.dart';
import 'models/game_options.dart';
import 'screens/game_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/options_screen.dart';
import 'screens/name_input_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GameOptions gameOptions = GameOptions();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruleta Rusa',
      theme: gameOptions.getTheme(),
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}
class WoodenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const WoodenButton({
    required this.text,
    required this.onPressed,
    this.width = 250,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/madera.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(3, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(color: Colors.brown.shade900, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cinzel', // ¡ideal si tienes una fuente antigua!
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(1.5, 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _MenuScreenState extends State<MenuScreen> {
  // Usuarios predefinidos
  final User user1 = User(
    id: '1',
    name: 'Usuario 1',
    wins: 0,
    losses: 0,
    avatarUrl: null,
    lives: 2,
    heartColor: Colors.red,
  );

  final User user2 = User(
    id: '2',
    name: 'Usuario 2',
    wins: 0,
    losses: 0,
    avatarUrl: null,
    lives: 2,
    heartColor: Colors.blue,
  );

  final AudioPlayer audioPlayer = AudioPlayer();
  final GameOptions gameOptions = GameOptions();

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('audio/audio1.mp3'));
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'RULETA RUSA',
              //   style: TextStyle(
              //     fontSize: 48,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //     shadows: [
              //       Shadow(
              //         blurRadius: 10.0,
              //         color: Colors.black,
              //         offset: Offset(5.0, 5.0),
              //       ),
              //     ],
              //   ),
              // ),
              
              WoodenButton(
  text: 'JUGAR',
  onPressed: () {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NameInputScreen(
        user1: user1,
        user2: user2,
      ),
    ).then((_) {
      _showBulletsDialog(context);
    });
  },
),
SizedBox(height: 20),
WoodenButton(
  text: 'OPCIONES',
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OptionsScreen()),
    );
    if (result == true) setState(() {});
  },
),

              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }

  void _showBulletsDialog(BuildContext context) {
    int selectedBullets = 1;

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
            'SELECCIONA LAS BALAS',
            style: TextStyle(
              color: Colors.amber[100],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                  'Número de balas: $selectedBullets',
                  style: TextStyle(
                    color: Colors.amber[100],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.amber[600],
                    inactiveTrackColor: Colors.brown[600],
                    thumbColor: Colors.amber,
                    overlayColor: Colors.amber.withOpacity(0.3),
                    valueIndicatorColor: Colors.amber[700],
                    valueIndicatorTextStyle: TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: selectedBullets.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: selectedBullets.toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedBullets = value.round();
                      });
                    },
                  ),
                ),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.amber[100],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          user1: user1,
                          user2: user2,
                          bullets: selectedBullets,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'CONFIRMAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
