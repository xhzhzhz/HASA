class PointService {
  static final PointService _instance = PointService._internal();
  factory PointService() => _instance;
  PointService._internal();

  int _points = 1250;
  final List<String> _notifications = ['Selamat datang di HASA! 100 poin'];

  int get points => _points;
  List<String> get notifications => _notifications;

  void addPoints(int amount, String message) {
    _points += amount;
    _notifications.insert(0, '$message: $amount poin');
  }
}
