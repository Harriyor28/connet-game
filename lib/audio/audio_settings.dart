class AudioSettings {
  const AudioSettings({
    this.musicEnabled = true,
    this.musicVolume = 0.7,
    this.sfxEnabled = true,
    this.sfxVolume = 0.8,
    this.voiceEnabled = true,
    this.voiceVolume = 0.85,
    this.hapticsEnabled = true,
  });

  final bool musicEnabled;
  final double musicVolume;
  final bool sfxEnabled;
  final double sfxVolume;
  final bool voiceEnabled;
  final double voiceVolume;
  final bool hapticsEnabled;

  AudioSettings copyWith({
    bool? musicEnabled,
    double? musicVolume,
    bool? sfxEnabled,
    double? sfxVolume,
    bool? voiceEnabled,
    double? voiceVolume,
    bool? hapticsEnabled,
  }) {
    return AudioSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
