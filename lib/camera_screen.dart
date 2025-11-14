import 'dart:math';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCameraActive = false;
  bool _isLoading = false;
  String _cameraError = '';
  final List<DetectedObject> _detectedObjects = [];
  double _focalLength = 1000.0; // Фокусное расстояние в пикселях
  late Random _random;

  @override
  void initState() {
    super.initState();
    _random = Random();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Навигационный помощник - Камера'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopCamera();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Text(
              'Режим компьютерного зрения',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Основная область камеры
          Expanded(
            child: _buildCameraArea(),
          ),

          // Панель управления
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Активация камеры...'),
          ],
        ),
      );
    }

    if (_cameraError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _cameraError,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Камера готова к работе',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Нажмите "Активировать камеру" для начала\nнавигационной помощи',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Активировать камеру'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      );
    }

    // Имитация работающей камеры с обнаружением объектов
    return _buildSimulatedCameraView();
  }

  Widget _buildSimulatedCameraView() {
    return Stack(
      children: [
        // Фон - имитация видеопотока
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, size: 80, color: Colors.white54),
                const SizedBox(height: 10),
                const Text(
                  'КАМЕРА АКТИВНА',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Обнаружено объектов: ${_detectedObjects.length}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Наложение с обнаруженными объектами
        _buildObjectOverlay(),

        // Информационная панель
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.yellow, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Обнаружено объектов: ${_detectedObjects.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Отладочная информация
        Positioned(
          bottom: 100,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Фокус: ${_focalLength.toStringAsFixed(0)}px',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObjectOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        painter: ObjectDetectionPainter(_detectedObjects),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Статус камеры
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Статус камеры:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isCameraActive ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isCameraActive ? 'АКТИВНА' : 'НЕАКТИВНА',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Кнопки управления
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isCameraActive ? _stopCamera : _initializeCamera,
                icon: const Icon(Icons.camera_alt),
                label: Text(_isCameraActive ? 'Выключить' : 'Включить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCameraActive ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isCameraActive ? _detectObjects : null,
                icon: const Icon(Icons.visibility),
                label: const Text('Сканировать'),
              ),
              ElevatedButton.icon(
                onPressed: _isCameraActive ? _checkDangers : null,
                icon: const Icon(Icons.warning),
                label: const Text('Опасности'),
              ),
            ],
          ),

          // Настройки калибровки
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Фокусное расстояние:'),
              Expanded(
                child: Slider(
                  value: _focalLength,
                  min: 500,
                  max: 2000,
                  divisions: 15,
                  label: _focalLength.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _focalLength = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _cameraError = '';
    });

    try {
      // Имитация загрузки камеры
      await Future.delayed(const Duration(seconds: 2));

      // Проверяем поддержку камеры в браузере
      final hasCameraSupport = await _checkCameraSupport();
      
      if (!hasCameraSupport) {
        throw Exception('Камера не поддерживается в этом браузере');
      }

      setState(() {
        _isLoading = false;
        _isCameraActive = true;
      });

      // Автоматическое обнаружение объектов каждые 3 секунды
      _startAutoDetection();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _cameraError = 'Не удалось получить доступ к камере. Используется режим симуляции.';
        _isCameraActive = true; // Все равно активируем симуляцию
      });
    }
  }

  Future<bool> _checkCameraSupport() async {
    // В реальном приложении здесь была бы проверка поддержки камеры
    // Для симуляции всегда возвращаем true
    return true;
  }

  void _startAutoDetection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isCameraActive) {
        _detectObjects();
        _startAutoDetection();
      }
    });
  }

  void _stopCamera() {
    setState(() {
      _isCameraActive = false;
      _detectedObjects.clear();
    });
  }

  void _detectObjects() {
    if (!_isCameraActive) return;

    // Реалистичная имитация обнаружения объектов с расчетами расстояний
    final newObjects = <DetectedObject>[];

    // Генерируем случайные объекты с реалистичными параметрами
    final objectCount = _random.nextInt(4) + 1; // 1-4 объекта
    
    for (int i = 0; i < objectCount; i++) {
      final objectType = ObjectType.values[_random.nextInt(ObjectType.values.length)];
      final objectWidth = _getObjectWidth(objectType);
      final pixelWidth = 50.0 + _random.nextInt(150); // Ширина в пикселях (50-200px)
      final distance = _calculateDistance(pixelWidth, objectWidth);
      
      // Создаем реалистичное bounding box
      final bboxLeft = 0.1 + _random.nextDouble() * 0.7;
      final bboxTop = 0.1 + _random.nextDouble() * 0.7;
      final bboxWidth = 0.1 + _random.nextDouble() * 0.3;
      final bboxHeight = bboxWidth * 0.75; // Сохраняем пропорции
      
      final object = DetectedObject(
        name: _getObjectName(objectType),
        distance: distance,
        direction: _getRandomDirection(),
        type: objectType,
        boundingBox: Rect.fromLTWH(bboxLeft, bboxTop, bboxWidth, bboxHeight),
        confidence: 0.7 + _random.nextDouble() * 0.25, // 0.7-0.95
      );
      
      newObjects.add(object);
    }

    setState(() {
      _detectedObjects.clear();
      _detectedObjects.addAll(newObjects);
    });

    // Показываем уведомление
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Обнаружено ${_detectedObjects.length} объектов'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  double _calculateDistance(double pixelWidth, double realWidth) {
    // Формула расчета расстояния: distance = (realWidth * focalLength) / pixelWidth
    final distance = (realWidth * _focalLength) / pixelWidth;
    // Округляем до 0.1 метра для реалистичности
    return (distance * 10).round() / 10.0;
  }

  double _getObjectWidth(ObjectType type) {
    switch (type) {
      case ObjectType.person:
        return 0.5; // Средняя ширина человека в метрах
      case ObjectType.door:
        return 0.9; // Ширина двери
      case ObjectType.chair:
        return 0.4; // Ширина стула
      case ObjectType.table:
        return 0.8; // Ширина стола
      case ObjectType.car:
        return 1.8; // Ширина автомобиля
    }
  }

  String _getObjectName(ObjectType type) {
    switch (type) {
      case ObjectType.person:
        return 'Человек';
      case ObjectType.door:
        return 'Дверь';
      case ObjectType.chair:
        return 'Стул';
      case ObjectType.table:
        return 'Стол';
      case ObjectType.car:
        return 'Автомобиль';
    }
  }

  String _getRandomDirection() {
    final directions = ['спереди', 'спереди слева', 'спереди справа', 'слева', 'справа'];
    return directions[_random.nextInt(directions.length)];
  }

  void _checkDangers() {
    final dangers = _detectedObjects.where((obj) => obj.distance < 3.0).toList();

    if (dangers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Прямых опасностей не обнаружено'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 10),
              Text('Обнаружены близкие объекты'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final danger in dangers.take(3))
                Text('• ${danger.name} в ${danger.distance.toStringAsFixed(1)}м (${danger.direction})'),
              const SizedBox(height: 10),
              const Text('Рекомендуется осторожность при движении.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }
}

// Классы для работы с обнаруженными объектами
enum ObjectType { person, door, chair, table, car }

class DetectedObject {
  final String name;
  final double distance;
  final String direction;
  final ObjectType type;
  final Rect boundingBox;
  final double confidence;

  const DetectedObject({
    required this.name,
    required this.distance,
    required this.direction,
    required this.type,
    required this.boundingBox,
    required this.confidence,
  });
}

// Кастомный painter для отрисовки bounding boxes
class ObjectDetectionPainter extends CustomPainter {
  final List<DetectedObject> objects;

  ObjectDetectionPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.black.withOpacity(0.7),
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final obj in objects) {
      // Выбираем цвет в зависимости от расстояния
      if (obj.distance < 2.0) {
        paint.color = Colors.red;
      } else if (obj.distance < 5.0) {
        paint.color = Colors.orange;
      } else {
        paint.color = Colors.green;
      }

      // Рисуем bounding box
      final rect = Rect.fromLTWH(
        obj.boundingBox.left * size.width,
        obj.boundingBox.top * size.height,
        obj.boundingBox.width * size.width,
        obj.boundingBox.height * size.height,
      );
      
      canvas.drawRect(rect, paint);

      // Рисуем текст с информацией
      final text = '${obj.name} ${obj.distance.toStringAsFixed(1)}м';
      textPainter.text = TextSpan(
        text: text,
        style: textStyle,
      );
      
      textPainter.layout();
      
      // Рисуем фон для текста
      final textBackground = Rect.fromLTWH(
        rect.left,
        rect.top - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );
      
      final backgroundPaint = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(textBackground, backgroundPaint);
      
      // Рисуем текст
      textPainter.paint(
        canvas,
        Offset(rect.left + 4, rect.top - textPainter.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}