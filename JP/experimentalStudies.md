## 実験的研究

バージョン5.1以降，jMetalは実験的研究，すなわち一連のアルゴリズムがいくつかの問題を解決し，結果としていくつかの出力ファイル(ラテックステーブル，Rスクリプト)が生成される実験を構成するためのサポートを組み込んでいる．

実験的研究のいくつかの例は，jMetal5.2:

- [NSGAIIStudy](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/NSGAIIStudy.java): 5つのZDT実数符号化問題を解くために，NSGA-IIの4つの変数(polynomial mutationとSBX交叉分布指数の値が異なる)がテストされる．この実験では，コンフィギュレーションごとに25の独立した実行が行われ，8つのコアが使用されている．

- [NSGAIIStudy2](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/NSGAIIStudy2.java): 以前と同じだが，参照パレートフロントは未知であると仮定されているため，問題ごとに全てのアルゴリズムによって得られた全てのfrontから得られる．各アルゴリズムの山椒への寄与も計算される(連続問題の場合のみ)．

- [ZDTStudy](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/ZDTStudy.java): `NSGAIIStudy`と同じであるが，NSGA-II，SPEA2およびSMPSOの3つの異なるアルゴリズムが比較される

- [ZDTStudy2](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/ZDTStudy2.java): 前と同じだが，山椒パレートフロントは`NSGAIIStudy`のように計算される

- [BinaryProblemsStudy](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/BinaryProblemsStudy.java): バイナリコード化問題を解く実験の例

- [ZDTScalabilityIStudy](https://github.com/jMetal/jMetal/blob/jmetal-5.2/jmetal-exec/src/main/java/org/uma/jmetal/experiment/ZDTScalabilityIStudy.java): これは実験的研究で同じ問題のいくつかの変数を使用する方法の例である．具体的には，この研究ではZDT1問題の5つの変数を解決することについて，それぞれが異なる決定変数の数を有することについて述べる
