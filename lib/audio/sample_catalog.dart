class SampleRef {
  const SampleRef({required this.name, required this.assetPath});

  final String name;
  final String assetPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SampleRef &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath;

  @override
  int get hashCode => assetPath.hashCode;
}

class Preset {
  const Preset({required this.name, required this.samples});

  final String name;
  final List<SampleRef> samples;
}

class SampleCatalog {
  static final List<Preset> presets = [
    Preset(
      name: 'Ketipung',
      samples: _samples('ket', 'Ketipung Kulit', '🍂'),
    ),
    Preset(
      name: 'Pong',
      samples: _samples('pong', 'Pong Dangdut', '🎯'),
    ),
    Preset(
      name: 'Simbaru',
      samples: _samples('sim', 'Simbaru', '🥁'),
    ),
    Preset(
      name: 'Darbuka',
      samples: _samples('dar', 'Darbuka', '🪘'),
    ),
    Preset(
      name: 'Hadroh',
      samples: _samples('had', 'Hadroh Real', '🧎'),
    ),
    Preset(
      name: 'Drum Kit',
      samples: _samples('drum', 'Drum Kit', '🎙️'),
    ),
  ];

  static List<SampleRef> _samples(String prefix, String label, String emoji) {
    return List<SampleRef>.generate(
      12,
      (index) {
        final number = (index + 1).toString().padLeft(2, '0');
        return SampleRef(
          name: '$label $number $emoji',
          assetPath: 'assets/presets/$prefix${index + 1}.wav',
        );
      },
      growable: false,
    );
  }

  /// Complete collection of 100+ authentic built-in sounds for pad customization
  static const List<SampleRef> allBuiltinSounds = [
    // Ketipung Kulit
    SampleRef(name: 'Ketipung Kulit 01 🍂', assetPath: 'assets/presets/ket1.wav'),
    SampleRef(name: 'Ketipung Kulit 02 🍂', assetPath: 'assets/presets/ket2.wav'),
    SampleRef(name: 'Ketipung Kulit 03 🍂', assetPath: 'assets/presets/ket3.wav'),
    SampleRef(name: 'Ketipung Kulit 04 🍂', assetPath: 'assets/presets/ket4.wav'),
    SampleRef(name: 'Ketipung Kulit 05 🍂', assetPath: 'assets/presets/ket5.wav'),
    SampleRef(name: 'Ketipung Kulit 06 🍂', assetPath: 'assets/presets/ket6.wav'),
    SampleRef(name: 'Ketipung Kulit 07 🍂', assetPath: 'assets/presets/ket7.wav'),
    SampleRef(name: 'Ketipung Kulit 08 🍂', assetPath: 'assets/presets/ket8.wav'),
    SampleRef(name: 'Ketipung Kulit 09 🍂', assetPath: 'assets/presets/ket9.wav'),
    SampleRef(name: 'Ketipung Kulit 10 🍂', assetPath: 'assets/presets/ket10.wav'),
    SampleRef(name: 'Ketipung Kulit 11 🍂', assetPath: 'assets/presets/ket11.wav'),
    SampleRef(name: 'Ketipung Kulit 12 🍂', assetPath: 'assets/presets/ket12.wav'),

    // Pong Dangdut
    SampleRef(name: 'Pong Dangdut 01 🎯', assetPath: 'assets/presets/pong1.wav'),
    SampleRef(name: 'Pong Dangdut 02 🎯', assetPath: 'assets/presets/pong2.wav'),
    SampleRef(name: 'Pong Dangdut 03 🎯', assetPath: 'assets/presets/pong3.wav'),
    SampleRef(name: 'Pong Dangdut 04 🎯', assetPath: 'assets/presets/pong4.wav'),
    SampleRef(name: 'Pong Dangdut 05 🎯', assetPath: 'assets/presets/pong5.wav'),
    SampleRef(name: 'Pong Dangdut 06 🎯', assetPath: 'assets/presets/pong6.wav'),
    SampleRef(name: 'Pong Dangdut 07 🎯', assetPath: 'assets/presets/pong7.wav'),
    SampleRef(name: 'Pong Dangdut 08 🎯', assetPath: 'assets/presets/pong8.wav'),
    SampleRef(name: 'Pong Dangdut 09 🎯', assetPath: 'assets/presets/pong9.wav'),
    SampleRef(name: 'Pong Dangdut 10 🎯', assetPath: 'assets/presets/pong10.wav'),
    SampleRef(name: 'Pong Dangdut 11 🎯', assetPath: 'assets/presets/pong11.wav'),
    SampleRef(name: 'Pong Dangdut 12 🎯', assetPath: 'assets/presets/pong12.wav'),

    // Simbaru
    SampleRef(name: 'Simbaru 01 🥁', assetPath: 'assets/presets/sim1.wav'),
    SampleRef(name: 'Simbaru 02 🥁', assetPath: 'assets/presets/sim2.wav'),
    SampleRef(name: 'Simbaru 03 🥁', assetPath: 'assets/presets/sim3.wav'),
    SampleRef(name: 'Simbaru 04 🥁', assetPath: 'assets/presets/sim4.wav'),
    SampleRef(name: 'Simbaru 05 🥁', assetPath: 'assets/presets/sim5.wav'),
    SampleRef(name: 'Simbaru 06 🥁', assetPath: 'assets/presets/sim6.wav'),
    SampleRef(name: 'Simbaru 07 🥁', assetPath: 'assets/presets/sim7.wav'),
    SampleRef(name: 'Simbaru 08 🥁', assetPath: 'assets/presets/sim8.wav'),
    SampleRef(name: 'Simbaru 09 🥁', assetPath: 'assets/presets/sim9.wav'),
    SampleRef(name: 'Simbaru 10 🥁', assetPath: 'assets/presets/sim10.wav'),
    SampleRef(name: 'Simbaru 11 🥁', assetPath: 'assets/presets/sim11.wav'),
    SampleRef(name: 'Simbaru 12 🥁', assetPath: 'assets/presets/sim12.wav'),

    // Darbuka & Bendir
    SampleRef(name: 'Darbuka 01 🪘', assetPath: 'assets/presets/dar1.wav'),
    SampleRef(name: 'Darbuka 02 🪘', assetPath: 'assets/presets/dar2.wav'),
    SampleRef(name: 'Darbuka 03 🪘', assetPath: 'assets/presets/dar3.wav'),
    SampleRef(name: 'Darbuka 04 🪘', assetPath: 'assets/presets/dar4.wav'),
    SampleRef(name: 'Darbuka 05 🪘', assetPath: 'assets/presets/dar5.wav'),
    SampleRef(name: 'Darbuka 06 🪘', assetPath: 'assets/presets/dar6.wav'),
    SampleRef(name: 'Darbuka 07 🪘', assetPath: 'assets/presets/dar7.wav'),
    SampleRef(name: 'Darbuka 08 🪘', assetPath: 'assets/presets/dar8.wav'),
    SampleRef(name: 'Darbuka 09 🪘', assetPath: 'assets/presets/dar9.wav'),
    SampleRef(name: 'Darbuka 10 🪘', assetPath: 'assets/presets/dar10.wav'),
    SampleRef(name: 'Darbuka 11 🪘', assetPath: 'assets/presets/dar11.wav'),
    SampleRef(name: 'Darbuka 12 🪘', assetPath: 'assets/presets/dar12.wav'),
    SampleRef(name: 'Darbuka Bendir 01 🪘', assetPath: 'assets/presets/darbuka_bendir1.wav'),
    SampleRef(name: 'Darbuka Bendir 02 🪘', assetPath: 'assets/presets/darbuka_bendir2.wav'),
    SampleRef(name: 'Darbuka Bendir 03 🪘', assetPath: 'assets/presets/darbuka_bendir3.wav'),
    SampleRef(name: 'Darbuka Bendir 04 🪘', assetPath: 'assets/presets/darbuka_bendir4.wav'),
    SampleRef(name: 'Darbuka Bendir 05 🪘', assetPath: 'assets/presets/darbuka_bendir5.wav'),

    // Hadroh & Bass Hadroh
    SampleRef(name: 'Bass Jikjik Hadroh 🔊', assetPath: 'assets/presets/bassjikjikhadroh.wav'),
    SampleRef(name: 'Bass Panjang Hadroh 🔊', assetPath: 'assets/presets/basspanjanghadroh.wav'),
    SampleRef(name: 'Hadroh Real 01 🧎', assetPath: 'assets/presets/had1.wav'),
    SampleRef(name: 'Hadroh Real 02 🧎', assetPath: 'assets/presets/had2.wav'),
    SampleRef(name: 'Hadroh Real 03 🧎', assetPath: 'assets/presets/had3.wav'),
    SampleRef(name: 'Hadroh Real 04 🧎', assetPath: 'assets/presets/had4.wav'),
    SampleRef(name: 'Hadroh Real 05 🧎', assetPath: 'assets/presets/had5.wav'),
    SampleRef(name: 'Hadroh Real 06 🧎', assetPath: 'assets/presets/had6.wav'),
    SampleRef(name: 'Hadroh Real 07 🧎', assetPath: 'assets/presets/had7.wav'),
    SampleRef(name: 'Hadroh Real 08 🧎', assetPath: 'assets/presets/had8.wav'),
    SampleRef(name: 'Hadroh Real 09 🧎', assetPath: 'assets/presets/had9.wav'),
    SampleRef(name: 'Hadroh Real 10 🧎', assetPath: 'assets/presets/had10.wav'),
    SampleRef(name: 'Hadroh Real 11 🧎', assetPath: 'assets/presets/had11.wav'),
    SampleRef(name: 'Hadroh Real 12 🧎', assetPath: 'assets/presets/had12.wav'),
    SampleRef(name: 'Hadroh Real 13 🧎', assetPath: 'assets/presets/hadroh13.wav'),

    // Jaranan
    SampleRef(name: 'Jaranan 01 💥', assetPath: 'assets/presets/jan1.wav'),
    SampleRef(name: 'Jaranan 02 💥', assetPath: 'assets/presets/jan2.wav'),
    SampleRef(name: 'Jaranan 03 💥', assetPath: 'assets/presets/jan3.wav'),
    SampleRef(name: 'Jaranan 04 💥', assetPath: 'assets/presets/jan4.wav'),
    SampleRef(name: 'Jaranan 05 💥', assetPath: 'assets/presets/jan5.wav'),
    SampleRef(name: 'Jaranan 06 💥', assetPath: 'assets/presets/jan6.wav'),
    SampleRef(name: 'Jaranan 07 💥', assetPath: 'assets/presets/jan7.wav'),
    SampleRef(name: 'Jaranan 08 💥', assetPath: 'assets/presets/jan8.wav'),
    SampleRef(name: 'Jaranan 09 💥', assetPath: 'assets/presets/jan9.wav'),
    SampleRef(name: 'Jaranan 10 💥', assetPath: 'assets/presets/jan10.wav'),
    SampleRef(name: 'Jaranan 11 💥', assetPath: 'assets/presets/jan11.wav'),
    SampleRef(name: 'Jaranan 12 💥', assetPath: 'assets/presets/jan12.wav'),

    // Langgam Jawa
    SampleRef(name: 'Langgam Jawa 01 👑', assetPath: 'assets/presets/langgam1.wav'),
    SampleRef(name: 'Langgam Jawa 02 👑', assetPath: 'assets/presets/langgam2.wav'),
    SampleRef(name: 'Langgam Jawa 03 👑', assetPath: 'assets/presets/langgam3.wav'),
    SampleRef(name: 'Langgam Jawa 04 👑', assetPath: 'assets/presets/langgam4.wav'),
    SampleRef(name: 'Langgam Jawa 05 👑', assetPath: 'assets/presets/langgam5.wav'),
    SampleRef(name: 'Langgam Jawa 06 👑', assetPath: 'assets/presets/langgam6.wav'),
    SampleRef(name: 'Langgam Jawa 07 👑', assetPath: 'assets/presets/langgam7.wav'),
    SampleRef(name: 'Langgam Jawa 08 👑', assetPath: 'assets/presets/langgam8.wav'),

    // Efek Suara
    SampleRef(name: 'Efek Suara Aaahhh 🗣️', assetPath: 'assets/presets/aaahhh.wav'),
    SampleRef(name: 'Efek Suara Asoy 💃', assetPath: 'assets/presets/asoy.wav'),
    SampleRef(name: 'Efek Suara Gajah 🐘', assetPath: 'assets/presets/gajah.wav'),
    SampleRef(name: 'Efek Suara Ready ⚡', assetPath: 'assets/presets/ready.wav'),
    SampleRef(name: 'Efek Suara Tarik Cak 🔥', assetPath: 'assets/presets/tarikcak.wav'),
    SampleRef(name: 'Efek Suara Tetetet 🎺', assetPath: 'assets/presets/tetetet.wav'),

    // Drum Kit
    SampleRef(name: 'Drum Kit 01 🎙️', assetPath: 'assets/presets/drum1.wav'),
    SampleRef(name: 'Drum Kit 02 🎙️', assetPath: 'assets/presets/drum2.wav'),
    SampleRef(name: 'Drum Kit 03 🎙️', assetPath: 'assets/presets/drum3.wav'),
    SampleRef(name: 'Drum Kit 04 🎙️', assetPath: 'assets/presets/drum4.wav'),
    SampleRef(name: 'Drum Kit 05 🎙️', assetPath: 'assets/presets/drum5.wav'),
    SampleRef(name: 'Drum Kit 06 🎙️', assetPath: 'assets/presets/drum6.wav'),
    SampleRef(name: 'Drum Kit 07 🎙️', assetPath: 'assets/presets/drum7.wav'),
    SampleRef(name: 'Drum Kit 08 🥁', assetPath: 'assets/presets/drum8.wav'),
    SampleRef(name: 'Drum Kit 09 🎙️', assetPath: 'assets/presets/drum9.wav'),
    SampleRef(name: 'Drum Kit 10 🎙️', assetPath: 'assets/presets/drum10.wav'),
    SampleRef(name: 'Drum Kit 11 🎙️', assetPath: 'assets/presets/drum11.wav'),
    SampleRef(name: 'Drum Kit 12 🎙️', assetPath: 'assets/presets/drum12.wav'),

    // Paralon
    SampleRef(name: 'Paralon 01 🎵', assetPath: 'assets/presets/paralon1.wav'),
    SampleRef(name: 'Paralon 02 🎵', assetPath: 'assets/presets/paralon2.wav'),
    SampleRef(name: 'Paralon 03 🎵', assetPath: 'assets/presets/paralon3.wav'),
    SampleRef(name: 'Paralon 04 🎵', assetPath: 'assets/presets/paralon4.wav'),
    SampleRef(name: 'Paralon 05 🎵', assetPath: 'assets/presets/paralon5.wav'),
    SampleRef(name: 'Paralon 06 🎵', assetPath: 'assets/presets/paralon6.wav'),
    SampleRef(name: 'Paralon 07 🎵', assetPath: 'assets/presets/paralon7.wav'),
    SampleRef(name: 'Paralon 08 🎵', assetPath: 'assets/presets/paralon8.wav'),
    SampleRef(name: 'Paralon 09 🎵', assetPath: 'assets/presets/paralon9.wav'),
    SampleRef(name: 'Paralon 10 🎵', assetPath: 'assets/presets/paralon10.wav'),
    SampleRef(name: 'Paralon 11 🎵', assetPath: 'assets/presets/paralon11.wav'),
  ];
}
