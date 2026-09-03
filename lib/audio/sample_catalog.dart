class SampleRef {
  const SampleRef({required this.name, required this.assetPath});

  final String name;
  final String assetPath;
}

class Preset {
  const Preset({required this.name, required this.samples});

  final String name;
  final List<SampleRef> samples;
}

class SampleCatalog {
  static final List<Preset> presets = [
    Preset(name: 'Ketipung', samples: _samples('ket', 'KET')),
    Preset(name: 'Pong', samples: _samples('pong', 'PONG')),
    Preset(name: 'Simbaru', samples: _samples('sim', 'SIM')),
    Preset(name: 'Darbuka', samples: _samples('dar', 'DAR')),
    Preset(name: 'Hadroh', samples: _samples('had', 'HAD')),
    Preset(name: 'Drum Kit', samples: _samples('drum', 'DRUM')),
  ];

  static List<SampleRef> _samples(String prefix, String label) {
    return List<SampleRef>.generate(
      12,
      (index) => SampleRef(
        name: '$label ${index + 1}',
        assetPath: 'assets/presets/$prefix${index + 1}.wav',
      ),
      growable: false,
    );
  }
}
