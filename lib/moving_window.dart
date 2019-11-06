class MovingWindowSpeed {
  List<double> _list;
  int _capacity;
  double _sum;

  MovingWindowSpeed.withCapacity(int capacity) {
    this._list = new List();
    this._capacity = capacity;
    this._sum = 0;
  }

  void clear() {
    _list.clear();
    _sum = 0;
  }

  void add(double element) {
    if (_list.length >= _capacity) {
      double removed = _list.removeAt(0);
      _sum = _sum - removed;
    }
    _list.add(element);
    _sum = _sum + element;
  }

  getMinKm() {
    double avgKmh = _calculateAverageKmh();

    double minKm = avgKmh == 0.0 ? 0.0 : (60 / avgKmh);

    int minPart = minKm.toInt();

    int secPart = ((minKm - minPart) * 60).toInt();

//    print("${avgKmh.toStringAsFixed(2)}\t${minKm}\t$minPart:$secPart");

    return "${minPart.toString().padLeft(2, "0")}:${secPart.toString().padLeft(2, "0")}";
  }

  String getKmH() {
    return _calculateAverageKmh().toStringAsFixed(2);
  }

  double _calculateAverageKmh(){
    return _average() * 3.6;
  }

  double _average() {
    return _sum / _list.length;
  }
}
