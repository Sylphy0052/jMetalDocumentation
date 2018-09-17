## `Algorithm`インターフェース
jMetal5のメタヒューリスティックまたはアルゴリズムは`Algorithm`インターフェースを実装する実体(Entity)である．

```java
package org.uma.jmetal.algorithm;

/**
 * Interface representing an algorithm
 * @author Antonio J. Nebro
 * @version 0.1
 * @param <Result> Result
 */
public interface Algorithm<Result> extends Runnable {
  void run() ;
  Result getResult() ;
}

```

このインターフェースは非常に一般的である．アルゴリズムは`run()`メソッドを持っていなければならず，`getResult()`メソッドで結果を返すように指定する．`Runnable`を拡張するので，どのアルゴリズムもスレッドで実行できる．

`Algorithm`の単純さは好きな好みに応じてメタヒューリスティックを実装する自由を豊富に提供する．しかし，jMetal5はフレームワークなので，優れたデザイン，コードの再利用，柔軟性を促進するという考え方でアルゴリズムの実装を支援する一連のリソースと戦略が含まれている．主要なコンポーネントは，[Builderパターン](https://en.wikipedia.org/wiki/Builder_pattern)と[アルゴリズム templates](https://github.com/jMetal/jMetalDocumentation/blob/master/algorithmTemplates.md)の使用である．次のセクションでは，よく知られているNSGA-IIアルゴリズムの実装，構成，および拡張の詳細について説明する．

### Case study: NSGA-II
NSGA-IIは遺伝的アルゴリズム(GA)であり，すなわち進化アルゴリズム(EA)に属する．jMetal5で提供されるNSGA-IIの実装はドキュメントの[アルゴリズムテンプレート](https://github.com/jMetal/jMetalDocumentation/blob/master/algorithmTemplates.md)セクションで説明されている進化的アルゴリズムテンプレートに従う．つまり,
[`AbstractEvolutionaryAlgorithm`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/algorithm/impl/AbstractEvolutionaryAlgorithm.java)クラスのメソッドを定義する必要がある．このテンプレートによれば，アルゴリズムのフロー制御は`run()`メソッドで定義される．

```java
@Override public void run() {
    List<S> offspringPopulation;
    List<S> matingPopulation;

    population = createInitialPopulation();
    population = evaluatePopulation(population);
    initProgress();
    while (!isStoppingConditionReached()) {
      matingPopulation = selection(population);
      offspringPopulation = reproduction(matingPopulation);
      offspringPopulation = evaluatePopulation(offspringPopulation);
      population = replacement(population, offspringPopulation);
      updateProgress();
    }
  }
```

次にこれらのメソッドが[NSGA-II](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/nsgaii/NSGAII.java)クラスでどのように実装されるかについて説明する．

クラスの宣言は次のとおりである．

```java
public class NSGAII<S extends Solution<?>> extends AbstractGeneticAlgorithm<S, List<S>> {
   ...
}
```

[`AbstractGeneticAlgorithm`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/algorithm/impl/AbstractGeneticAlgorithm.java)を拡張していることを示す．一般的な`S`は，アルゴリズムを操作する解のコードかを指定することを可能にし，解ける問題の種類と使用可能なオペレータを決定する．これはクラスコンストラクタで例証されている．

```java
 public NSGAII(Problem<S> problem, int maxIterations, int populationSize,
      CrossoverOperator<S> crossoverOperator, MutationOperator<S> mutationOperator,
      SelectionOperator<List<S>, S> selectionOperator, SolutionListEvaluator<S> evaluator) {
    super() ;
    this.problem = problem;
    this.maxIterations = maxIterations;
    this.populationSize = populationSize;

    this.crossoverOperator = crossoverOperator;
    this.mutationOperator = mutationOperator;
    this.selectionOperator = selectionOperator;

    this.evaluator = evaluator;
  }
```

コンストラクタパラメータには次のものが含まれる．

- 解決すべき問題
- 主要なアルゴリズムパラメータ: 母集団のサイズと反復の最大回数
- 遺伝子オペレータ: 交叉，突然変異，選択
- 母集団内の解を評価するための[評価指標](./evaluators.md)オブジェクト

全てのパラメータは`S`に依存することがわかる．このようにして`S`がインスタンス化される場合，例えば[`DoubleSolution`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/solution/DoubleSolution.java)を拡張しなければならない問題は，`Problem<DoubleSolution>`を拡張しなければならず，全てのオペレータは`DoubleSolution`オブジェクトを操作しなければならない．このアプローチの興味深い点はコンパイラが誤ったオペレータを特定のソリューションに適用する際のエラーがないことを保証できることである．

デフォルトの`createInitialPopulation()`メソッドはいくつかの`populationSize`新しい解をリストに追加する．

```java
  @Override protected List<S> createInitialPopulation() {
    List<S> population = new ArrayList<>(populationSize);
    for (int i = 0; i < populationSize; i++) {
      S newIndividual = problem.createSolution();
      population.add(newIndividual);
    }
    return population;
  }
```

解のリストの評価は`Evaluator`オブジェクトに委譲されるので，`evaluatePopulation()`メソッドは非常に簡単である．

```java
  @Override protected List<S> evaluatePopulation(List<S> population) {
    population = evaluator.evaluate(population, problem);

    return population;
  }
```

NSGA-IIの実装では，停止条件は最大反復回数の周りに定義されると仮定している．

```java
  @Override protected boolean isStoppingConditionReached() {
    return iterations >= maxIterations;
  }
```

なので，`initProgress()`メソッドは反復カウンタを初期化する．(初期値はすでに評価されているため，初期値は1である)

```java
  @Override protected void initProgress() {
    iterations = 1;
  }
```

`updateProgress()`メソッドは単にカウンタをインクリメントする．

```java
  @Override protected void updateProgress() {
    iterations++;
  }

```

EAテンプレートに合致するように`Selection()`メソッドは集団からの後輩プールを作成しなければならないので，以下のように実装される．

```java
  @Override protected List<S> selection(List<S> population) {
    List<S> matingPopulation = new ArrayList<>(population.size());
    for (int i = 0; i < populationSize; i++) {
      S solution = selectionOperator.execute(population);
      matingPopulation.add(solution);
    }

    return matingPopulation;
  }
```

`reproduction()`メソッドは交叉と突然変異オペレータを交配プールを作成しなければならないので，以下のように実装される．

```java
  @Override protected List<S> reproduction(List<S> population) {
    List<S> offspringPopulation = new ArrayList<>(populationSize);
    for (int i = 0; i < populationSize; i += 2) {
      List<S> parents = new ArrayList<>(2);
      parents.add(population.get(i));
      parents.add(population.get(i + 1));

      List<S> offspring = crossoverOperator.execute(parents);

      mutationOperator.execute(offspring.get(0));
      mutationOperator.execute(offspring.get(1));

      offspringPopulation.add(offspring.get(0));
      offspringPopulation.add(offspring.get(1));
    }
    return offspringPopulation;
  }
```

最後に，`replacement()`メソッドは現在と子孫の集団を結合して，次世代の集団を生成する．

```java
  @Override protected List<S> replacement(List<S> population, List<S> offspringPopulation) {
    List<S> jointPopulation = new ArrayList<>();
    jointPopulation.addAll(population);
    jointPopulation.addAll(offspringPopulation);

    Ranking<S> ranking = computeRanking(jointPopulation);

    return crowdingDistanceSelection(ranking);
  }
```

### Case study: Steady-state(定常状態) NSGA-II
EAテンプレートを使用してNSGA-IIを実装する利点は，アルゴリズムのバリエーションの実装を簡素化できることである．ここでは，NSGA-IIの定常状態バージョンを実装する[SteadyStateNSGAII](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/nsgaii/SteadyStateNSGAII.java)クラスについて例を挙げて説明する．このバージョンは基本的にはNSGA-IIだが，サイズ1の人口が豊富なので，`SteadyStateNSGAII`は[`NSGAII`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/nsgaii/NSGAII.java)クラスの拡張である．

```java
public class SteadyStateNSGAII<S extends Solution<?>> extends NSGAII<S> {
}
```

クラスコンストラクタはNSGA-IIのものに似ている．

``` java
  public SteadyStateNSGAII(Problem<S> problem, int maxIterations, int populationSize,
      CrossoverOperator<S> crossoverOperator, MutationOperator<S> mutationOperator,
      SelectionOperator<List<S>, S> selectionOperator, SolutionListEvaluator<S> evaluator) {
    super(problem, maxIterations, populationSize, crossoverOperator, mutationOperator,
        selectionOperator, evaluator);
  }
```

2つのアルゴリズムバリエーションの唯一の違いは，`section()`(交配プールは2つの親からなる)と`reproduction()`(子のみが生成される)

```java
  @Override protected List<S> selection(List<S> population) {
    List<S> matingPopulation = new ArrayList<>(2);

    matingPopulation.add(selectionOperator.execute(population));
    matingPopulation.add(selectionOperator.execute(population));

    return matingPopulation;
  }

  @Override protected List<S> reproduction(List<S> population) {
    List<S> offspringPopulation = new ArrayList<>(1);

    List<S> parents = new ArrayList<>(2);
    parents.add(population.get(0));
    parents.add(population.get(1));

    List<S> offspring = crossoverOperator.execute(parents);

    mutationOperator.execute(offspring.get(0));

    offspringPopulation.add(offspring.get(0));
    return offspringPopulation;
  }
```

この方法では，`NSGA-II`クラスのコードの大部分が再利用され，2つのメソッドしか再定義されない．

### Builderパターンを使用してNSGA-IIを構成する
jMetal5でアルゴリズムを設定するために，[`AlgorithmBuilder`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/util/AlgorithmBuilder.java)インターフェースで表現されるbuilderパターンを使い方法を採用した．

```java
/**
 * Interface representing algorithm builders
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 */
public interface AlgorithmBuilder<A extends Algorithm<?>> {
  public A build() ;
}
```

TO BE COMPLETED

[4 周辺アーキテクチャ](peripheralArchitecture.md)
