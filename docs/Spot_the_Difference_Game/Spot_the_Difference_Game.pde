import ddf.minim.*; // minimライブラリをインポート
Minim minim; // minim型の変数
AudioPlayer correctsound, wrongsound, opening, ending;
MyImage[] mi = new MyImage[5]; // MyImageクラスの myimage オブジェクトを格納する変数を宣言
int score = 0;                 //獲得ポイントの合計
int imageNumber = 0;           //間違い探しの画像を変更する番号
int st_res = 0;                //タイトル画面と結果の画面を表示させる番号
int time = 120;                //残り時間
int second = 0;                //残り時間を1秒ずつ減らすための変数
int point[] = new int[5];      //いくつ答えられたか記録する配列
PImage[] ans = new PImage[5];  //答えの画像を入れる配列
boolean batu = false;          //間違った箇所にバツを表示させるトリガー

float p = 255;                 //バツの不透明度を管理
int x = 0;                     //バツつけるためにクリック時のx座標を管理
int y = 0;                     //バツつけるためにクリック時のy座標を管理

float t = 150;                 //ヒントの不透明度を管理
int   u = 1;                   //ヒントの不透明度を管理（増減）
boolean a = false;             //ヒント表示のトリガー
int count = 30;                //ヒントを表示するための経過時間をカウント

PImage op;                     //オープニング画像を入れる変数

void setup() {
  size(800, 800);
  imageMode(CENTER);
  ellipseMode(CENTER);
  textAlign(CENTER);

  //音の初期化
  minim = new Minim(this); // minimを初期化
  correctsound = minim.loadFile("data/correct.mp3");
  wrongsound = minim.loadFile("data/wrong.mp3");
  opening = minim.loadFile("data/op.mp3");
  ending = minim.loadFile("data/result.mp3");

  //各配列の初期化
  mi[0] = new MyImage("data/L1.jpg", "data/R1.jpg", "data/bgm1.mp3", 125, 245, 50, 310, 253, 50, 129, 655, 50);  //画像以降は「答えのx座標、y座標、当たりの直径」×３
  mi[1] = new MyImage("data/L2.jpg", "data/R2.jpg", "data/bgm2.mp3", 111, 368, 50, 259, 381, 50, 134, 515, 50);
  mi[2] = new MyImage("data/L3.jpg", "data/R3.jpg", "data/bgm3.mp3", 83, 267, 50, 41, 439, 50, 305, 548, 50);
  mi[3] = new MyImage("data/L4.jpg", "data/R4.jpg", "data/bgm4.mp3", 230, 215, 50, 67, 347, 50, 344, 550, 50);
  mi[4] = new MyImage("data/L5.jpg", "data/R5.jpg", "data/bgm5.mp3", 48, 134, 50, 222, 483, 50, 373, 537, 50);

  ans[0] = loadImage("data/ans1.jpg");
  ans[1] = loadImage("data/ans2.jpg");
  ans[2] = loadImage("data/ans3.jpg");
  ans[3] = loadImage("data/ans4.jpg");
  ans[4] = loadImage("data/ans5.jpg");

  op = loadImage("data/op.png");          //オープニング画像を代入

  for (int i=0; i<5; i++) {
    ans[i].resize(150, 0);                //答え合わせの画像をリサイズ
  }

  for (int i=0; i<5; i++) {
    point[i]=0;                           //各問題の正解数をリセット
  }

  //文字の色と太さ
  fill(240, 244, 245);
  noStroke();
}

//---------------------------------------------------------------
//              　　　　     draw関数
//---------------------------------------------------------------
void draw() {
  background(177, 188, 234);
  textAlign(CENTER);
  PFont font2 = createFont("TsukuARdGothic-Bold", 64);
  PFont font1 = createFont("TsukuARdGothic-Regular", 64); 

  //-----------------------スタート画面--------------------------
  if (st_res==0) {
    imageMode(CENTER);
    opening.play();
    image(op, width/2, height/2);
    if (keyCode==ENTER) {
      st_res++;
    }
  }

  //--------------------間違い探し画面-------------------------
  if (st_res != 0 && st_res != 6) {
    opening.pause();
    opening.rewind();                      //タイトルの曲を停止・巻き戻し
    mi[imageNumber].playSound();           //BGMを再生
    mi[imageNumber].hyouji();              //間違い探しの画像を表示
    mi[imageNumber].mark();                //正解した箇所に印をつける

    //---------------30秒経って丸が出なかったらヒント表示------------
    if (count<0) {
      a = true;
      fill(227, 169, 98, t);
      noStroke();
      mi[imageNumber].hint();  //ヒントを表示する関数を実行
      if (t>150 || t<0) {
        u *= -1;               //不透明度変化のプラマイを変更
      }
      t += 2*u;                //不透明度を変更
    }

    //----------------------ばつ印を表示-------------------------
    if (batu==true) {
      noFill();
      stroke(38, 116, 222, p);
      strokeWeight(6);
      if (p>=0) {
        mi[imageNumber].setBatu(x, y);      //バツを表示する関数を実行
        p -= 0.3;                           //バツの不透明度を減らす
      }
    }

    rectMode(CENTER);
    fill(190, 196, 222);
    noStroke();
    rect(width/2, 54.5, width, 109);
    rect(width/2, 745.5, width, 109);

    //文字の色と太さ
    fill(250, 250, 248);
    textFont(font2);
    textSize(30);
    textAlign(LEFT);
    text("左側の画像をクリックして間違いを見つけよう !", 15, 35);

    textFont(font1);
    fill(245, 223, 223);
    noStroke();
    textSize(25);
    text("あと" + score + "/3", 10, 100);
    fill(255, 255, 167);
    text("残り時間：" + time + "秒", 590, 750);
    second++;
    if (second%60==0) {
      time--;
      count--;
    }
  }



  //---------------------結果発表の画面--------------------------
  if (st_res==6) {
    background(240, 238, 216);
    ending.play();
    textAlign(CENTER);
    fill(82, 67, 35);
    textSize(80);
    textFont(font2);
    text("結果発表", width/2, 129);
    textFont(font1);
    textSize(18);
    text("1問目："+point[0]+"/3　　"+"2問目："+point[1]+"/3　　"+"3問目："+point[2]+"/3　　"+"4問目："+point[3]+"/3　　"+"5問目："+point[4]+"/3　", width/2, 215);

    textSize(25);
    text("〜答え合わせ〜", width/2, 380);

    imageMode(CORNER);
    image(ans[0], 15, 400);
    image(ans[1], 170, 400);
    image(ans[2], 325, 400);
    image(ans[3], 480, 400);
    image(ans[4], 635, 400);

    //見つけられた箇所の合計を計算
    int finalpoint = point[0]+point[1]+point[2]+point[3]+point[4];

    if (finalpoint>=15) {
      textFont(font2);
      textSize(45);
      fill(216,113,145);
      text("全問正解おめでとう !!", width/2, 305);
    } else if (finalpoint>=10 && finalpoint<15) {
      textFont(font2);
      textSize(45);
      fill(121,181,149);
      text("もう少し...!", width/2, 305);
    } else if (finalpoint>=0 && finalpoint<10) {
      textFont(font2);
      textSize(45);
      fill(121,137,181);
      text("焦らずやってみよう", width/2, 305);
    }

    //-----------------リセット-----------------------------
    textAlign(RIGHT);
    textFont(font2);
    textSize(35);
    fill(82, 67, 35);
    text(">>Qで最初から", 780, 770);
    if (keyCode=='Q') {                     //Qキーを押すとリセット
      ending.pause();
      ending.rewind();                      //結果発表の曲を停止・巻き戻し
      mi[0].reset();                        //変数の値をリセットする関数を実行
    }
  }
}

//-------------------------------------------------------------
//           　　　　　 クリック時のアクション
//------------------------------------------------------------
void mousePressed() {
  if (st_res > 0 && st_res < 6) {
    p = 100;                                    //バツの不透明度ををリセット
    batu=false;                                 //バツ表示のトリガーをリセット
    mi[imageNumber].answer(mouseX, mouseY);     //クリック座標と正解座標の照らし合わせ
    x = mouseX;
    y = mouseY;
  }
}


//-----------------------------------------------------------
//　　　　　　　 　　　　　　　　MyImageクラス
//-----------------------------------------------------------
class MyImage {
  //------------------使用する変数の定義-----------------------//
  PImage imgL; // 画像を保持する変数
  PImage imgR; // 画像を保持する変数
  AudioPlayer player; // 音を再生するための変数

  float[] ans_x = new float[3];
  float[] ans_y = new float[3];
  float[] dia = new float[3];

  boolean[] mark = new boolean[3];         //正解した箇所のマークを出すか否か。trueになったら表示


  //---------------------------変数の初期化----------------------------------//
  MyImage(String image_fileL, String image_fileR, String sound_file, float x1, float y1, float r1, float x2, float y2, float r2, float x3, float y3, float r3) {
    imgL = loadImage(image_fileL);          //画像の読み込み
    imgR = loadImage(image_fileR);          //　〃
    imgL.resize(400, 0);                    //画像のリサイズ
    imgR.resize(400, 0);                    //　〃

    player = minim.loadFile(sound_file);

    ans_x[0]= x1;
    ans_x[1]= x2;
    ans_x[2]= x3;

    ans_y[0]= y1;
    ans_y[1]= y2;
    ans_y[2]= y3;

    dia[0]= r1;
    dia[1]= r2;
    dia[2]= r3;

    for (int i=0; i<3; i++) {
      mark[i]=false;                 //正解箇所をクリックしたか否かをリセット
    }
  }

  //---------------------- void hyouji(画面の切り替え) -------------------------------//
  void hyouji() {
    imageMode(CENTER);
    image(imgL, width/4, height/2);
    image(imgR, width/4*3, height/2);

    //三箇所見つけたらor時間切れになったら次の画像へ移動・スコアと時間をリセット
    if (mark[0]==true && mark[1]==true && mark[2]==true || time<0) {
      if (imageNumber<6) {
        point[imageNumber] = score;            //いくつ正解したかを、正解数を記録する変数に代入
        score = 0;                             //いくつ正解したかをリセット
        second = 0;                            //カウントダウン用の変数をリセット
        time = 120;                            //残り時間をリセット
        count = 30;                            //ヒント表示までの残り時間をリセット
        mi[imageNumber].stopSound();           //次のBGMのために現在のBGMを止める
        batu=false;                            //バツ表示のトリガーをリセット
        for (int i=0; i<3; i++) {
          mark[i]=false;
        }
        //最終問題のみimageNumberを加算させない
        if (imageNumber==4) {
          st_res++;
        } else {
          imageNumber++;
          st_res++;
        }
      }
    }
  }

  //------------- void answer(クリック時の座標が答えの座標と被っているか確認) ------------------//
  void answer(int clickX, int clickY) {
    float [] distance = new float[3];                              //クリック座標と答えの座標の距離を管理する配列

    //2点間の距離を計算
    for (int i=0; i<3; i++) {
      distance[i] = dist(ans_x[i], ans_y[i], clickX, clickY);      //配列にクリック座標と答えの座標の距離を代入
    }

    //被っていた場合、ポイントが加算され、答えの場所に丸が表示されるキューを出す。また、ヒントの表示カウントダウンをリセットする
    if (distance[0]<=dia[0]||distance[1]<=dia[1]||distance[2]<=dia[2]) {   
      if (distance[0]<=dia[0]) {
        if (mark[0]==false) {
          correctsound.play(0);
          score += 1;
          count = 30;
          mark[0]=true;
        }
      } else if (distance[1]<=dia[1]) {
        if (mark[1]==false) {
          correctsound.play(0);
          score += 1;
          count = 30;
          mark[1]=true;
        }
      } else if (distance[2]<=dia[2]) {
        if (mark[2]==false) {
          correctsound.play(0);
          score += 1;
          count = 30;
          mark[2]=true;
        }
      }
    } else {
      wrongsound.play(0);
      time -= 7;
      batu = true;
    }
  }
  //------------------------ void mark(正解の箇所に丸を表示) ---------------------------//
  void mark() {
    noFill();
    stroke(232, 52, 73, 180);
    strokeWeight(5);
    if (mark[0]==true) {
      ellipse(ans_x[0], ans_y[0], dia[0], dia[0]);
    }
    if (mark[1]==true) {
      ellipse(ans_x[1], ans_y[1], dia[1], dia[1]);
    }
    if (mark[2]==true) {
      ellipse(ans_x[2], ans_y[2], dia[2], dia[2]);
    }
  }


  //------------------------ void setBatu(間違えてクリックした箇所にバツを表示) ---------------------------//
  void setBatu(int x, int y) {
    line(x-20, y-20, x+20, y+20);
    line(x-20, y+20, x+20, y-20);
  }

  //------------------------ void hint(ヒント表示) ---------------------------//
  void hint() {
    rectMode(CENTER);
    if (a==true) {
      if (mark[0]==false) {
        rect(width/4, ans_y[0], width/2, 100);
      } else if (mark[1]==false) {
        rect(width/4, ans_y[1], width/2, 100);
      } else if (mark[2]==false) {
        rect(width/4, ans_y[2], width/2, 100);
      }
      a = false;
    }
  }

  //----------------------BGMを流すか---------------------//
  void playSound() {
    player.play(); // 音源を再生
  }

  void stopSound() {
    player.pause(); // 音を停止
    player.rewind(); // 音を巻き戻し
  }

  //----------------------リセット---------------------//
  void reset() {
    score = 0;                 //獲得ポイントの合計
    imageNumber = 0;           //間違い探しの画像を変更する番号
    st_res = 0;                //タイトル画面と結果の画面を表示させる番号
    time = 120;                //残り時間
    second = 0;                //残り時間を1秒ずつ減らすための変数

    batu = false;             //間違った箇所にバツを表示させるトリガー

    p = 255;                  //バツの不透明度を管理
    x = 0;                     //バツつけるためにクリック時のx座標を管理
    y = 0;                     //バツつけるためにクリック時のy座標を管理

    t = 150;                 //ヒントの不透明度を管理
    u = 1;                   //ヒントの不透明度を管理（増減）
    a = false;               //ヒント表示のトリガー
    count = 30;              //ヒントを表示するための経過時間をカウント
    for (int i=0; i<3; i++) {
      mark[i]=false;
    }
    for (int i=0; i<5; i++) {
      point[i]=0;
    }
  }
}
