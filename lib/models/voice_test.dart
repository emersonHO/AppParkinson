class VoiceTest {
  final int? id;
  final String userId;
  final String date;
  final double probability;
  final String level;
  final double? fo;
  final double? fhi;
  final double? flo;
  final double? jitterPercent;
  final double? jitterAbs;
  final double? rap;
  final double? ppq;
  final double? ddp;
  final double? shimmer;
  final double? shimmerDb;
  final double? apq3;
  final double? apq5;
  final double? apq;
  final double? dda;
  final double? nhr;
  final double? hnr;
  final double? rpde;
  final double? dfa;
  final double? spread1;
  final double? spread2;
  final double? d2;
  final double? ppe;

  VoiceTest({
    this.id,
    required this.userId,
    required this.date,
    required this.probability,
    required this.level,
    this.fo,
    this.fhi,
    this.flo,
    this.jitterPercent,
    this.jitterAbs,
    this.rap,
    this.ppq,
    this.ddp,
    this.shimmer,
    this.shimmerDb,
    this.apq3,
    this.apq5,
    this.apq,
    this.dda,
    this.nhr,
    this.hnr,
    this.rpde,
    this.dfa,
    this.spread1,
    this.spread2,
    this.d2,
    this.ppe,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date,
      'probability': probability,
      'level': level,
      'fo': fo,
      'fhi': fhi,
      'flo': flo,
      'jitter_percent': jitterPercent,
      'jitter_abs': jitterAbs,
      'rap': rap,
      'ppq': ppq,
      'ddp': ddp,
      'shimmer': shimmer,
      'shimmer_db': shimmerDb,
      'apq3': apq3,
      'apq5': apq5,
      'apq': apq,
      'dda': dda,
      'nhr': nhr,
      'hnr': hnr,
      'rpde': rpde,
      'dfa': dfa,
      'spread1': spread1,
      'spread2': spread2,
      'd2': d2,
      'ppe': ppe,
    };
  }

  factory VoiceTest.fromJson(Map<String, dynamic> json) {
    return VoiceTest(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      date: json['date'] ?? '',
      probability: (json['probability'] ?? 0.0).toDouble(),
      level: json['level'] ?? '',
      fo: json['fo']?.toDouble(),
      fhi: json['fhi']?.toDouble(),
      flo: json['flo']?.toDouble(),
      jitterPercent: json['jitter_percent']?.toDouble() ?? json['jitterPercent']?.toDouble(),
      jitterAbs: json['jitter_abs']?.toDouble() ?? json['jitterAbs']?.toDouble(),
      rap: json['rap']?.toDouble(),
      ppq: json['ppq']?.toDouble(),
      ddp: json['ddp']?.toDouble(),
      shimmer: json['shimmer']?.toDouble(),
      shimmerDb: json['shimmer_db']?.toDouble() ?? json['shimmerDb']?.toDouble(),
      apq3: json['apq3']?.toDouble(),
      apq5: json['apq5']?.toDouble(),
      apq: json['apq']?.toDouble(),
      dda: json['dda']?.toDouble(),
      nhr: json['nhr']?.toDouble(),
      hnr: json['hnr']?.toDouble(),
      rpde: json['rpde']?.toDouble(),
      dfa: json['dfa']?.toDouble(),
      spread1: json['spread1']?.toDouble(),
      spread2: json['spread2']?.toDouble(),
      d2: json['d2']?.toDouble(),
      ppe: json['ppe']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date,
      'probability': probability,
      'level': level,
      'fo': fo,
      'fhi': fhi,
      'flo': flo,
      'jitter_percent': jitterPercent,
      'jitter_abs': jitterAbs,
      'rap': rap,
      'ppq': ppq,
      'ddp': ddp,
      'shimmer': shimmer,
      'shimmer_db': shimmerDb,
      'apq3': apq3,
      'apq5': apq5,
      'apq': apq,
      'dda': dda,
      'nhr': nhr,
      'hnr': hnr,
      'rpde': rpde,
      'dfa': dfa,
      'spread1': spread1,
      'spread2': spread2,
      'd2': d2,
      'ppe': ppe,
    };
  }

  factory VoiceTest.fromMap(Map<String, dynamic> map) {
    return VoiceTest(
      id: map['id'],
      userId: map['user_id'] ?? '',
      date: map['date'] ?? '',
      probability: (map['probability'] ?? 0.0).toDouble(),
      level: map['level'] ?? '',
      fo: map['fo']?.toDouble(),
      fhi: map['fhi']?.toDouble(),
      flo: map['flo']?.toDouble(),
      jitterPercent: map['jitter_percent']?.toDouble(),
      jitterAbs: map['jitter_abs']?.toDouble(),
      rap: map['rap']?.toDouble(),
      ppq: map['ppq']?.toDouble(),
      ddp: map['ddp']?.toDouble(),
      shimmer: map['shimmer']?.toDouble(),
      shimmerDb: map['shimmer_db']?.toDouble(),
      apq3: map['apq3']?.toDouble(),
      apq5: map['apq5']?.toDouble(),
      apq: map['apq']?.toDouble(),
      dda: map['dda']?.toDouble(),
      nhr: map['nhr']?.toDouble(),
      hnr: map['hnr']?.toDouble(),
      rpde: map['rpde']?.toDouble(),
      dfa: map['dfa']?.toDouble(),
      spread1: map['spread1']?.toDouble(),
      spread2: map['spread2']?.toDouble(),
      d2: map['d2']?.toDouble(),
      ppe: map['ppe']?.toDouble(),
    );
  }
}






