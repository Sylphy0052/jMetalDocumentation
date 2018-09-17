## 品質インジケータ

品質指標は，コアパッケージのコンポーネント(jmetal-core)としてjMetal5で考慮されている．他の多くのコンポーネントと同様に，汎用インターフェースと，そのインターフェースの提供された実装を含む`impl`パッケージがある．

`QualityIndicator`インターフェースは非常に単純である．

```java
package org.uma.jmetal.qualityindicator;

/**
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 *
 * @param <Evaluate> Entity to evaluate
 * @param <Result> Result of the evaluation
 */
public interface QualityIndicator<Evaluate, Result> extends DescribedEntity {
  public Result evaluate(Evaluate evaluate) ;
  public String getName() ;
}
```

アイデアは全ての品質インジケータが評価されるいくつかのエンティティ(`Evaluate`)に適用され，`Result`を返す．Genericの使用はSet Converageの実装の場合のように，Double value(最も普通の戻り値型)から値のペアまで，何かを返すインジケータを表すことができる．品質インジケータには，関連する名前もある．

### 補助クラス
品質インジケータの実装方法を説明する前に，使用するいくつかの補助クラスの前にコメントする必要がある．

- [`Front`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/util/front/Front.java)インターフェースと[`ArrayFront`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/util/front/imp/ArrayFront.java)クラス: 頻繁に，山椒パレートフロントは，いくつかの会の客観的な値を含むファイルに格納される．`Front`はこれらのファイルの内容を格納することを意図したエンティティである．`ArrayFront`クラスの場合，フロントは天の配列に格納される．
- [`FrontNormalizer`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/util/front/util/FrontNormalizer.java)クラス: 多くの指標が評価対象の解のリストを正規化する．このクラスはこれを行うことを意図している．参照の先頭，または最大値と最小値を指定すると，正規化された会のリストを返す．

### インジケータの例: Epsilon
jMetal5の品質インジケータを説明するために，次にEpsilonインジケータのコードを説明する．

Epsilonクラスの宣言は次のコードに含まれている．

```java
public class Epsilon<Evaluate extends List<? extends Solution<?>>>
    extends SimpleDescribedEntity
    implements QualityIndicator<Evaluate,Double> {
  ...

```

一見すると，非常に複雑な宣言のように見えるが，`Evaluate`は任意の種類のjMetalの`Solution`のリストでなければならないと単純に述べている．したがってコンパイル時にインジケータを互換性のないオブジェクトとともに使用しようとする試みは検出される．

大部分のインジケータを実装するアプローチは，フロントエンドがクラスコンストラクタのパラメータとして組み込まれるように，それらの大部分が参照フロントを計算する必要があることを考慮することである．


```java
  private Front referenceParetoFront ;

  /**
   * Constructor
   *
   * @param referenceParetoFrontFile
   * @throws FileNotFoundException
   */
  public Epsilon(String referenceParetoFrontFile) throws FileNotFoundException {
    super("EP", "Epsilon quality indicator") ;
    if (referenceParetoFrontFile == null) {
      throw new JMetalException("The reference pareto front is null");
    }

    Front front = new ArrayFront(referenceParetoFrontFile);
    referenceParetoFront = front ;
  }
...
```

次に`evaluate`メソッドは参照フロントを使ってインジケータ値を計算する

```java
  /**
   * Evaluate() method
   *
   * @param solutionList
   * @return
   */
  @Override public Double evaluate(Evaluate solutionList) {
    if (solutionList == null) {
      throw new JMetalException("The pareto front approximation list is null") ;
    }

    return epsilon(new ArrayFront(solutionList), referenceParetoFront);
  }
```

Epsilonの計算方法は[ここ]( https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/qualityindicator/impl/Epsilon.java)から全てのコードを見つけることができる．

### 正規化について
考慮すべき重要な問題は，品質指標が評価されるべきソリューションリストを正規化しないことである．その代わり，ユーザはそれらを使用する前に正規化されているかどうかを選択することができる．

このコードはファイルからリファレンスを読み込む方法とそこから`FrontNormalized`を取得する方法の例を示している．

```java
Front referenceFront = new ArrayFront("fileName");
FrontNormalizer frontNormalizer = new FrontNormalizer(referenceFront) ;
```

次に，front normalizerを正規化されたreference frontに使用することができる

```java
Front normalizedReferenceFront = frontNormalizer.normalize(referenceFront) ;
```

そして，正規化されるべき解リストがあれば，このようにすることができる．

``` java
List<Solution> population ;
...
Front normalizedFront = frontNormalizer.normalize(new ArrayFront(population)) ;
```

### 品質インジケータの使用
正規化について決めたものは，品質インジケータを作成して使用することができる．Hypervolumeを例として選択する．

```java
Hypervolume<List<? extends Solution<?>>> hypervolume ;
hypervolume = new Hypervolume<List<? extends Solution<?>>>(referenceFront) ;

double hvValue = hypervolume.evaluate(population) ;
```

### Discussion
正規化をユーザに任せておくと，エラーが発生しやすくなるが，パフォーマンス状の利点がある．同じインジケータを多くのソリューションリストに適用する必要がある場合，参照フロントの正規化は1回だけ実行される．これは，例えば，インジケータベースのアルゴリズムの中には，Hypervolumeに最も貢献していないソリューションを見つけなければならない場合がある．

### コマンドラインから品質指標を計算する
コマンドラインからソリューションのフロントの所定の品質インジケータの値を計算する必要がある場合は，[`CommandLineIndicatorRunner`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-exec/src/main/java/org/uma/jmetal/qualityIndicator/CommandLineIndicatorRunner.java)クラスを使用できる．

このプログラムの使用方法は次の通りである．

```
java org.uma.jmetal.qualityIndicator.CommandLineIndicatorRunner indicatorName referenceFront frontToEvaluate TRUE | FALSE
```

インジケータ名は次の通りである．

- `GD`: Generational distance
- `IGD`: Inverted generational distance
- `IGD+`: Inverted generational distance plus
- `EP`: Epsilon
- `HV`: Hypervolume
- `SPREAD`: Spread (2つの目的)
- `GSPREAD`: Generalized spread (2つ以上の目的)
- `ER`: Error ratio(エラー率)
- `ALL`: 使用可能な全てのインジケータを選択

最後のパラメータは，品質インジケータを計算する前にfrontを正規化するかどうかを示すために使用される．

つぎに，　いくつかの例を示す．まず，NSGA-IIを実行し[`ZDT2`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-problem/src/main/java/org/uma/jmetal/problem/multiobjective/zdt/ZDT2.java)を解決する．

```
$ java org.uma.jmetal.runner.multiobjective.NSGAIIRunner org.uma.jmetal.problem.multiobjective.zdt.ZDT2

ago 01, 2015 6:08:16 PM org.uma.jmetal.runner.multiobjective.NSGAIIRunner main
INFORMACIÓN: Total execution time: 1445ms
ago 01, 2015 6:08:17 PM org.uma.jmetal.runner.AbstractAlgorithmRunner printFinalSolutionSet
INFORMACIÓN: Random seed: 1438445295477
ago 01, 2015 6:08:17 PM org.uma.jmetal.runner.AbstractAlgorithmRunner printFinalSolutionSet
INFORMACIÓN: Objectives values have been written to file FUN.tsv
ago 01, 2015 6:08:17 PM org.uma.jmetal.runner.AbstractAlgorithmRunner printFinalSolutionSet
INFORMACIÓN: Variables values have been written to file VAR.tsv
```

次は`CommandLineIndicatorRunner`を使用して，最初に正規化してHypervolume値を計算する

```
$ java org.uma.jmetal.qualityIndicator.CommandLineIndicatorRunner HV jmetal-problem/src/test/resources/pareto_fronts/ZDT2.pf FUN.tsv TRUE

The fronts are NORMALIZED before computing the indicators
0.32627228626895705
```

全ての品質インジケータの計算をする場合は次のコマンドを実行する．

```
$ java org.uma.jmetal.qualityIndicator.CommandLineIndicatorRunner ALL jmetal-problem/src/test/resources/pareto_fronts/ZDT2.pf FUN.tsv TRUE

The fronts are NORMALIZED before computing the indicators
EP: 0.01141025767271403
HV: 0.32627228626895705
GD: 1.862557951719542E-4
IGD: 1.8204928590462744E-4
IGD+: 0.003435437983027875
SPREAD: 0.33743702454536517
GSPREAD: 0.40369897027563534
R2: 0.19650995040071226
ER: 1.0
SC(refPF, front): 0.89
SC(front, refPF): 0.0
```

[7 前回の変更履歴](changelog.md)
