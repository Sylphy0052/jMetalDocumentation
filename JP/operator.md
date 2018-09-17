## `Operator`インターフェース
メタヒューリスティック技術は異なるオペレータのアプリケーションによって既存のソリューションから新しいソリューションを変更または生成することに基づいている．例えば，EAはソリューションを変更するために交叉，突然変異，および選択を使用する．jMetalでは，ソリューション(またはそれらのセット)を変更または生成する操作は全て，`Operator`インターフェースを実装または拡張する．

``` java
package org.uma.jmetal.operator;

/**
 * Interface representing an operator
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 * @version 0.1
 * @param <Source> Source Class of the object to be operated with
 * @param <Result> Result Class of the result obtained after applying the operator
 */
public interface Operator<Source, Result> {
  /**
   * @param source The data to process
   */
  public Result execute(Source source) ;
}

```
このインターフェースGenericsはオペレータが`Source`オブジェクトに適用され，結果として`Result`オブジェクトを返すことを示している．

このフレームワークにはすでに4つの異なるクラスに分類することができる複数のオペレータが組み込まれている．

- 交叉(Crossover):EAで使用される組換えまたは交叉オペレータを表す．含まれるオペレータには，それぞれ実数バイナリ(SBX)の交叉と実数およびバイナリのエンコードのためのSingle-poing crossoverがある．

- 突然変異(Mutation):EAで使用される突然変異オペレータを表す．含まれるオペレータの例には，polynomial mutation(real encoding)とbit-flip mutation(binary encoding)がある．

- 選択(Selection):この種のオペレータは，多くのメタヒューリスティックで選択手順を実行するために使用される．選択オペレータの例はバイナリトーナメントである．

- LocalSearch:このクラスは，ローカル検索プロシージャを表すためのものである．それは適用された後にいくつの評価が実行されたかを調べる方法を含んでいる．

次に，これらのオペレータのインタフェースと実装について説明する．

### 交叉(Crossover)オペレータ
`CrossoverOperator`インターフェースは，jMetal5内の任意の交叉を表す．

```java
package org.uma.jmetal.operator;

/**
 * Interface representing crossover operators. They will receive a list of solutions and return
 * another list of solutions
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 *
 * @param <S> The class of the solutions
 */
public interface CrossoverOperator<S extends Solution<?>> extends Operator<List<S>,List<S>> {
}
```

このインターフェースは，単に交叉がソースとして`Solution`オブジェクトのリストを持ち，結果として別のソリューションのリストを返す．このインターフェースの2つの実装を検討する．1つはdouble solutions，もう一つはbinary solutionsである．

シミュレートされたBinary crossover(SBX)は多くの多目的進化アルゴリズム(NSGA-II,SPEA2,SMS_EMOA,MOCellなど)におけるデフォルトのCrossoverオペレータである．次に`SBXCrossover`クラスのスキームを示す．

```java
package org.uma.jmetal.operator.impl.crossover;

/**
 * This class allows to apply a SBX crossover operator using two parent solutions (Double encoding).
 * A {@link RepairDoubleSolution} object is used to decide the strategy to apply when a value is out
 * of range.
 *
 * The implementation is based on the NSGA-II code available in
 * <a href="http://www.iitk.ac.in/kangal/codes.shtml">http://www.iitk.ac.in/kangal/codes.shtml</a>
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 * @author Juan J. Durillo
 */
public class SBXCrossover implements CrossoverOperator<DoubleSolution> {
  /** EPS defines the minimum difference allowed between real values */
  private static final double EPS = 1.0e-14;

  private double distributionIndex ;
  private double crossoverProbability  ;
  private RepairDoubleSolution solutionRepair ;

  private JMetalRandom randomGenerator ;

  /** Constructor */
  public SBXCrossover(double crossoverProbability, double distributionIndex) {
    this (crossoverProbability, distributionIndex, new RepairDoubleSolutionAtBounds()) ;
  }

  /** Constructor */
  public SBXCrossover(double crossoverProbability, double distributionIndex, RepairDoubleSolution solutionRepair) {
    if (crossoverProbability < 0) {
      throw new JMetalException("Crossover probability is negative: " + crossoverProbability) ;
    } else if (distributionIndex < 0) {
      throw new JMetalException("Distribution index is negative: " + distributionIndex);
    }

    this.crossoverProbability = crossoverProbability ;
    this.distributionIndex = distributionIndex ;
    this.solutionRepair = solutionRepair ;

    randomGenerator = JMetalRandom.getInstance() ;
  }

  /** Execute() method */
  @Override
  public List<DoubleSolution> execute(List<DoubleSolution> solutions) {
    if (null == solutions) {
      throw new JMetalException("Null parameter") ;
    } else if (solutions.size() != 2) {
      throw new JMetalException("There must be two parents instead of " + solutions.size()) ;
    }

    return doCrossover(crossoverProbability, solutions.get(0), solutions.get(1)) ;
  }

  ...
```

TO BE COMPLETED

[3.3 問題インターフェース](problem.md)
