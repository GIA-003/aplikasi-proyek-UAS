import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_logic.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int EMPTY = 0;
  static const int PLAYER = 1;
  static const int AI = 2;

  List<List<int>> board = List.generate(3, (_) => List.filled(3, EMPTY));
  bool isPlayerTurn = true;
  bool gameOver = false;
  List<List<int>> playerMoveHistory = [];
  List<List<int>> aiMoveHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Player vs AI',
              style: GoogleFonts.keaniaOne(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('/foto/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TRICTATIC',
                    style: GoogleFonts.keaniaOne(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'DUEL',
                    style: GoogleFonts.keaniaOne(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  int row = index ~/ 3;
                  int col = index % 3;
                  return GestureDetector(
                    onTap: () {
                      if (!gameOver && isPlayerTurn && board[row][col] == EMPTY) {
                        handlePlayerMove(row, col);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: _buildMark(row, col),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  resetGame();
                },
                child: Text('Reset Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMark(int row, int col) {
    if (board[row][col] == PLAYER) {
      return Text(
        'X',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      );
    } else if (board[row][col] == AI) {
      return Text(
        'O',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      );
    } else {
      return SizedBox(); // Kotak kosong
    }
  }

  void handlePlayerMove(int row, int col) {
    setState(() {
      board[row][col] = PLAYER;
      playerMoveHistory.add([row, col]); // Tambah gerakan pemain ke dalam moveHistory
      isPlayerTurn = false; // Setelah pemain bergerak, giliran AI
    });
    checkGameResult(row, col);
  }

  void makeAIMove() {
    Future.delayed(Duration(milliseconds: 500), () {
      List<int> aiMove = findBestMove(board);

      // Memeriksa apakah kotak yang dipilih AI sudah diisi oleh pemain sebelumnya
      if (board[aiMove[0]][aiMove[1]] == EMPTY) {
        setState(() {
          board[aiMove[0]][aiMove[1]] = AI;
          aiMoveHistory.add(aiMove); // Tambah gerakan AI ke dalam moveHistory
          isPlayerTurn = true; // Setelah AI bergerak, giliran pemain
        });
        checkGameResult(aiMove[0], aiMove[1]);
      } else {
        // Jika kotak sudah diisi, panggil makeAIMove() kembali untuk memilih kotak lain
        makeAIMove();
      }
    });
  }

  void checkGameResult(int lastRow, int lastCol) {
    int result = evaluate(board);
    if (result == 10) {
      _showDialog('AI wins!', 'assets/foto/win.jpg');
    } else if (result == -10) {
      _showDialog('You win!', 'assets/foto/lose.jpg');
    } else {
      if (isPlayerTurn) {
        // Giliran pemain, tunggu input dari pemain
        return;
      }
      // Giliran AI
      makeAIMove();
    }

    // Hapus gerakan terakhir dari moveHistory sesuai giliran
    if (result != 0) {
      if (result == 10) {
        aiMoveHistory.removeLast();
      } else if (result == -10) {
        playerMoveHistory.removeLast();
      }
    }

    // Periksa dan hapus gerakan pertama dari moveHistory pemain
    if (playerMoveHistory.length > 3) {
      List<int> firstPlayerMove = playerMoveHistory.removeAt(0);
      board[firstPlayerMove[0]][firstPlayerMove[1]] = EMPTY;
    }

    // Periksa dan hapus gerakan pertama dari moveHistory AI
    if (aiMoveHistory.length > 2) {
      List<int> firstAIMove = aiMoveHistory.removeAt(1);
      board[firstAIMove[0]][firstAIMove[1]] = EMPTY;
    }
  }

  void _showDialog(String message, String imagePath) {
    gameOver = true; // Setelah permainan selesai, atur gameOver menjadi true
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20.0), // Menentukan sudut sudutnya
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      resetGame();
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text('Play Again'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, EMPTY));
      isPlayerTurn = true;
      gameOver = false;
      // Bersihkan moveHistory pemain
      playerMoveHistory.clear();
      // Bersihkan moveHistory AI
      aiMoveHistory.clear();
    });
  }
}
