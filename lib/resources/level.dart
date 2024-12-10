class Level {
    static const double msPerFrame = 16.67; // approx 1/60 of sec in ms.

    // ms per piece drop. index with level number.
    static Map<int, int> levelsToSpeeds = <int, int>{
    0: (48 * msPerFrame).toInt(),
    1: (43 * msPerFrame).toInt(),
    2: (38 * msPerFrame).toInt(),
    3: (33 * msPerFrame).toInt(),
    4: (28 * msPerFrame).toInt(),
    5: (23 * msPerFrame).toInt(),
    6: (18 * msPerFrame).toInt(),
    7: (13 * msPerFrame).toInt(),
    8: (8 * msPerFrame).toInt(), 
    9: (6 * msPerFrame).toInt(),
    10: (5 * msPerFrame).toInt(),
    11: (5 * msPerFrame).toInt(),
    12: (5 * msPerFrame).toInt(),
    13: (4 * msPerFrame).toInt(),
    14: (4 * msPerFrame).toInt(),
    15: (4 * msPerFrame).toInt(),
    16: (3 * msPerFrame).toInt(),
    17: (3 * msPerFrame).toInt(),
    18: (3 * msPerFrame).toInt(),
    19: (2 * msPerFrame).toInt(),
    20: (2 * msPerFrame).toInt(),
    21: (2 * msPerFrame).toInt(),
    22: (2 * msPerFrame).toInt(),
    23: (2 * msPerFrame).toInt(),
    24: (2 * msPerFrame).toInt(),
    25: (2 * msPerFrame).toInt(),
    26: (2 * msPerFrame).toInt(),
    27: (2 * msPerFrame).toInt(),
    28: (2 * msPerFrame).toInt(),
    29: (msPerFrame).toInt(),
  };
}