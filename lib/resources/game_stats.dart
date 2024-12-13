import 'dart:math';

class GameStats {
  final int seedLevel;
  int level = 0;
  int score = 0;
  int totalLinesCleared = 0;
  int singles = 0;
  int doubles = 0;
  int triples = 0;
  int tetris = 0;
  int tSpinSingle = 0;
  int tSpinDouble = 0;

  GameStats({required this.seedLevel}) { level = seedLevel; }

  // Set the status and the score if we've cleared line(s).
  void updateStatsAfterLineClear(int linesCleared, bool tSpin, bool tetrisCleared) {
    totalLinesCleared += linesCleared;
    level = max(totalLinesCleared ~/ 10, seedLevel);

    double multiplier = 1;
    multiplier *= tSpin ? 12 : 1;
    multiplier *= (tetrisCleared && linesCleared == 4) ? 2 : 1;

    if (linesCleared == 1) {
      score += (40 * (level + 1) * multiplier).toInt();
      if (tSpin) {
        tSpinSingle++;
      }
      else {
        singles++;
      }
    }
    else if (linesCleared == 2) {
      score += (100 * (level + 1) * multiplier).toInt();
      if (tSpin) {
        tSpinDouble++;
      }
      else {
        tSpinDouble++;
      }
    }
    else if (linesCleared == 3) {
      score += (300 * (level + 1) * multiplier).toInt();
      triples++;
    }
    else if (linesCleared == 4) {
      score += (1200 * (level + 1) * multiplier).toInt();
      tetris++;
    }
  }
}