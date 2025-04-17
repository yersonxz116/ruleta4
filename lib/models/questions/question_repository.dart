import 'dart:math';
import 'question.dart';

class QuestionRepository {
  // Lista de preguntas predefinidas
  static final List<Question> _questions = [
    Question(
      text: '¿Cuál de las siguientes medidas es una medida de tendencia central?',
      options: ['Varianza', 'Media', 'Desviación estándar', 'Rango'],
      correctOptionIndex: 1,
    ),
    Question(
      text: 'En un conjunto de datos, la mediana es:',
      options: ['El valor más frecuente', 'El valor que divide el conjunto en dos partes iguales', 'La suma de todos los valores dividida por el número de valores', 'El valor máximo'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Qué representa la varianza en un conjunto de datos?',
      options: ['La media de los datos', 'La dispersión de los datos respecto a la media', 'El valor más bajo', 'La suma total de los datos'],
      correctOptionIndex: 1,
    ),
    Question(
      text: 'Si un evento tiene una probabilidad de 0.2, ¿cuál es la probabilidad de que no',
      options: ['0.2', '0.5', '0.8', '1.0'],
      correctOptionIndex: 2,
    ),
    Question(
      text: '¿Cuál de las siguientes afirmaciones es verdadera sobre la probabilidad?',
      options: ['La probabilidad siempre es negativa', 'La probabilidad de un evento es siempre mayor que 1', 'La probabilidad de un evento es un número entre 0 y 1', 'La probabilidad de un evento es siempre igual a 0'],
      correctOptionIndex: 2,
    ),
    Question(
      text: 'En un histograma, el área total de las barras representa:',
      options: ['La media', 'La frecuencia total', 'La probabilidad total', 'La varianza'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Qué tipo de distribución tiene una forma de campana y es simétrica?',
      options: ['Distribución uniforme', 'Distribución normal', 'Distribución binomial', 'Distribución exponencial'],
      correctOptionIndex: 1,
    ),
    Question(
      text: 'Si un conjunto de datos tiene una desviación estándar baja, esto indica que:',
      options: ['Los datos están muy dispersos', 'Los datos están muy concentrados alrededor de la media', 'Los datos son todos negativos', 'Los datos son todos positivos'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Cuál de las siguientes es una característica de la distribución binomial?',
      options: ['Solo puede tener dos resultados', 'Puede tener múltiples resultados', 'No tiene un número fijo de ensayos', 'No se puede calcular la probabilidad'],
      correctOptionIndex: 0,
    ),
    Question(
      text: 'La probabilidad de obtener un número par al lanzar un dado es:',
      options: ['1/2', '1/3', '1/6', '1/4'],
      correctOptionIndex: 0,
    ),
  ];

  // Obtener una pregunta aleatoria
  static Question getRandomQuestion() {
    final random = Random();
    return _questions[random.nextInt(_questions.length)];
  }
}