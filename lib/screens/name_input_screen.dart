import 'package:flutter/material.dart';
import '../models/user.dart';

class NameInputScreen extends StatefulWidget {
  final User user1;
  final User user2;

  const NameInputScreen({
    Key? key,
    required this.user1,
    required this.user2,
  }) : super(key: key);

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _user1Controller = TextEditingController();
  final TextEditingController _user2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user1Controller.text = widget.user1.name;
    _user2Controller.text = widget.user2.name;
  }

  @override
  void dispose() {
    _user1Controller.dispose();
    _user2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Validación de nombres al confirmar
    void validateAndUpdateNames() {
      setState(() {
        String name1 = _user1Controller.text.trim();
        String name2 = _user2Controller.text.trim();
        
        // Limitar longitud del nombre
        if (name1.length > 20) _user1Controller.text = name1.substring(0, 20);
        if (name2.length > 20) _user2Controller.text = name2.substring(0, 20);
      });
    }

    return AlertDialog(
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
          'Nombres de Jugadores',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _user1Controller,
              onChanged: (_) => validateAndUpdateNames(),
              style: TextStyle(color: Colors.amber[100]),
              decoration: InputDecoration(
                labelText: 'Jugador 1',
                labelStyle: TextStyle(color: Colors.amber[200]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber[100]!),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _user2Controller,
              onChanged: (_) => validateAndUpdateNames(),
              style: TextStyle(color: Colors.amber[100]),
              decoration: InputDecoration(
                labelText: 'Jugador 2',
                labelStyle: TextStyle(color: Colors.amber[200]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber[100]!),
                ),
              ),
            ),
          ],
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
              TextButton(
                onPressed: () {
                  // Validar y actualizar nombres
                  String name1 = _user1Controller.text.trim();
                  String name2 = _user2Controller.text.trim();

                  // Aplicar nombres predeterminados si están vacíos
                  if (name1.isEmpty) name1 = 'Usuario 1';
                  if (name2.isEmpty) name2 = 'Usuario 2';

                  // Actualizar nombres de usuarios
                  widget.user1.name = name1;
                  widget.user2.name = name2;

                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber[100],
                ),
                child: Text('Aceptar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}