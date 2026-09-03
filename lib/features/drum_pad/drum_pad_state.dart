class DrumPadState {
  DrumPadState({
    int activePresetIndex = 0,
    double masterVolume = 0.5,
    List<double>? padVolumes,
    this.leftHanded = false,
  })  : _activePresetIndex = _validatePreset(activePresetIndex),
        _masterVolume = _clamp(masterVolume),
        _padVolumes = List<double>.generate(
          12,
          (index) => _clamp(padVolumes?[index] ?? 1),
        );

  static const padCount = 12;
  static const presetCount = 6;

  int _activePresetIndex;
  double _masterVolume;
  final List<double> _padVolumes;
  bool leftHanded;

  int get activePresetIndex => _activePresetIndex;
  double get masterVolume => _masterVolume;
  List<double> get padVolumes => List.unmodifiable(_padVolumes);

  void selectPreset(int index) {
    _activePresetIndex = _validatePreset(index);
  }

  void setMasterVolume(double value) {
    _masterVolume = _clamp(value);
  }

  void setPadVolume(int index, double value) {
    if (index < 0 || index >= padCount) {
      throw RangeError.index(index, _padVolumes, 'index');
    }
    _padVolumes[index] = _clamp(value);
  }

  List<int> orderedPadIndices() {
    final indices = List<int>.generate(padCount, (index) => index);
    return leftHanded ? indices.reversed.toList() : indices;
  }

  static int _validatePreset(int index) {
    if (index < 0 || index >= presetCount) {
      throw RangeError.index(index, List.filled(presetCount, null), 'index');
    }
    return index;
  }

  static double _clamp(double value) => value.clamp(0, 1).toDouble();
}
