// game_logic.dart
import 'dart:math';

const int EMPTY = 0;
const int PLAYER = 1;
const int AI = 2;

List<int> findBestMove(List<List<int>> board) {
  int bestVal = -1000;
  List<int> bestMove = [-1, -1];

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[i][j] == EMPTY) {
        board[i][j] = AI;
        int moveVal = minimax(board, 0, false);
        board[i][j] = EMPTY;

        if (moveVal > bestVal) {
          bestMove = [i, j];
          bestVal = moveVal;
        }
      }
    }
  }
  return bestMove;
}

int minimax(List<List<int>> board, int depth, bool isMax) {
  int score = evaluate(board);

  if (score == 10) return score - depth;
  if (score == -10) return score + depth;
  if (!isMovesLeft(board) || depth >= 3) return 0;

  if (isMax) {
    int best = -1000;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == EMPTY) {
          board[i][j] = AI;
          best = max(best, minimax(board, depth + 1, !isMax));
          board[i][j] = EMPTY;
        }
      }
    }
    return best;
  } else {
    int best = 1000;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == EMPTY) {
          board[i][j] = PLAYER;
          best = min(best, minimax(board, depth + 1, !isMax));
          board[i][j] = EMPTY;
        }
      }
    }
    return best;
  }
}

bool isMovesLeft(List<List<int>> board) {
  for (var row in board) {
    if (row.contains(EMPTY)) {
      return true;
    }
  }
  return false;
}

int evaluate(List<List<int>> b) {
  for (int row = 0; row < 3; row++) {
    if (b[row][0] == b[row][1] && b[row][1] == b[row][2]) {
      if (b[row][0] == PLAYER) return -10;
      if (b[row][0] == AI) return 10;
    }
  }

  for (int col = 0; col < 3; col++) {
    if (b[0][col] == b[1][col] && b[1][col] == b[2][col]) {
      if (b[0][col] == PLAYER) return -10;
      if (b[0][col] == AI) return 10;
    }
  }

  if (b[0][0] == b[1][1] && b[1][1] == b[2][2]) {
    if (b[0][0] == PLAYER) return -10;
    if (b[0][0] == AI) return 10;
  }
  if (b[0][2] == b[1][1] && b[1][1] == b[2][0]) {
    if (b[0][2] == PLAYER) return -10;
    if (b[0][2] == AI) return 10;
  }

  if (!isMovesLeft(b)) {
    return 0;
  }

  return 0;
}
