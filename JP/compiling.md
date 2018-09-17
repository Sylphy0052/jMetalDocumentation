## コンパイル
jMetalのソースコードを取得したら，IDEまたは端末のコマンドラインから使用できる．IDEの代替として単純で，ツールに慣れていればアルゴリズムのコンパイルと実行は簡単である．

### Intellj Idea
プロジェクトをビルドするには`Build`→`Make Project`を選択する

![Building with IntelliJ Idea](./figures/BuildIJICE14.png)


### Eclipse
`Project`→`Build Automatically`が設定されるとEclipseは自動的にプロジェクトをビルドする．それ以外の場合は`Project`→`Build Project`を選択する．

![Building with Eclipse](./figures/BuildEclipse.png)

### Netbeans
Netbeansでは`Run`→`Build Project`を選択する必要がある．

![Building with Netbeans](./figures/BuildNetbeans.png)

### コマンドラインからのビルド
ソースコードをダウンロードしたら，Mavenコマンドを使ってプロジェクトをビルドすることができる．Terminalを開くと次のようになる．

![jMetal in a terminal](./figures/jMetalInTerminal.png)

Mavenの使い方

- `mvn clean`: プロジェクトのクリーニング
- `mvn compile`: コンパイル
- `mvn test`: テスト
- `mvn package`: コンパイル，テスト，ドキュメントの作成，jarファイルのパッケージ化
- `mvn site`: プロジェクトのサイトを生成する

[2.3 プログラムの実行](running.md)
