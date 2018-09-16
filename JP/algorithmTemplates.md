## アルゴリズムテンプレート
メタヒューリスティックなfamilyの大部分は，familyに属する全てのアルゴリズムによって共有される共通の行動によって特徴付けられる．この振る舞いは，特定のアルゴリズムを実装するために開始可能なテンプレートとして表現できる．ソフトウェアエンジニアリングの観点からは，振る舞いが基本テンプレートに含まれるアルゴリズムは，新しいテクニックのためのいくつかの特定のメソッドを実装する必要がある．共通の振る舞いをプログラムする必要がなくなるため，コードの複製が少なくなる．この制御の逆転は，jMetalの場合のように[software frameworks](https://en.wikipedia.org/wiki/Software_framework)の特性である．

### 進化的アルゴリズムテンプレート
進化的アルゴリズム(EAs)に関する多くの論文には，これに類似した擬似コードが含まれている．

```
P(0) ← GenerateInitialSolutions()
t ← 0
Evaluate(P(0))
while not StoppingCriterion() do
  P'(t) ← selection(P(t))
  P''(t) ← Variation(P'(t))
  Evaluate(P''(t))
  P (t + 1) ← Update(P (t), P''(t))
  t←t+1
end while
```

この擬似コードを模倣するために，jMetal5は，[`AbstractEvolutionaryAlgorithm`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/algorithm/impl/AbstractEvolutionaryAlgorithm.java)という名前の抽象クラスの形式でテンプレートを組み込みます．このテンプレートには，次のコードが含まれている．

```java
package org.uma.jmetal.algorithm.impl;

/**
 * Created by Antonio J. Nebro on 26/10/14.
 * @param <S> Solution
 * @param <R> Result
 */
public abstract class AbstractEvolutionaryAlgorithm<S extends Solution<?>, R>  implements Algorithm<R>{
  private List<S> population;
  public List<S> getPopulation() {
    return population;
  }
  public void setPopulation(List<S> population) {
    this.population = population;
  }

  protected abstract void initProgress();
  protected abstract void updateProgress();
  protected abstract boolean isStoppingConditionReached();
  protected abstract List<S> createInitialPopulation();
  protected abstract List<S> evaluatePopulation(List<S> population);
  protected abstract List<S> selection(List<S> population);
  protected abstract List<S> reproduction(List<S> population);
  protected abstract List<S> replacement(List<S> population, List<S> offspringPopulation);
  @Override public abstract R getResult();

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
}
```

クラス宣言のジェネリクスはアルゴリズムが`Solution`インターフェース(例えば`DoubleSolution`，`BinarySolution`など)のサブクラスで動作し，結果を返すことを示している(通常，客観的なメタヒューリスティックスト多目的手法の場合の解決策のリスト)．人口が解決策のリストとして実装されているので，観察することができる．

EAを開発するには，`run()`メソッドで使用されている全ての抽象メソッドを実装する必要がある．次にこれらの方法について説明する．

- `createInitialPopulation()`: この方法は人口を一連の暫定的な解で満たす．典型的な戦略は，ランダムに初期化された会を生成することにあるが，他の方法を適用することもできる
- `evaluatePopulation(population)`: `population`引数の全ての解が評価され，パラメータまたは新しいものとして渡されたものと同じである可能性のある母集団が結果として返される
- `initProgress()`: EAの進捗は，通常，反復または機能評価を数えることによって測定される．このメソッドは，Progessカウンタを初期化する．
- `isStoppingConditionReached()`: アルゴリズムがその実行を終了するときに停止条件が成立する
- `selection(population)`:選択方法は，集団から複数の会を選択して交配プールにする
- `reproduction(matingPopulation)`: 交配プール内の解は，それらを改変するか，またはそれらを用いて新しいものを作成することによって，なんらかの形で操作され，子孫集団を構成する新しい解答に帰着する
- `replacement(population, offspringPopulation)`: 次世代の人口は，現在の子孫と子孫の個体群から構成されている
- `updateProgress()`: アルゴリズムの信仰のカウンター(評価，反復など)が更新される

#### 遺伝的アルゴリズム
選択オペレータを適用し，再生ステップに交叉と突然変異オペレータを使用することによって特徴付けられる遺伝的アルゴリズムを実装することに興味がある場合，`AbstractGeneticAlgorithm`と呼ばれる[AbstractGeneticAlgorithm](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/algorithm/impl/AbstractGeneticAlgorithm.java)のサブクラスが提供される．

```java
package org.uma.jmetal.algorithm.impl;

/**
 * Created by ajnebro on 26/10/14.
 */
public abstract class AbstractGeneticAlgorithm<S extends Solution<?>, Result> extends AbstractEvolutionaryAlgorithm<S, Result> {
  protected SelectionOperator<List<S>, S> selectionOperator ;
  protected CrossoverOperator<S> crossoverOperator ;
  protected MutationOperator<S> mutationOperator ;
}
```

一般的なメタヒューリスティックの例

- [NSGA-II](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/nsgaii/NSGAII.java)

- [SPEA2](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/spea2/SPEA2.java)

- [PESA2](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/pesa2/PESA2.java)

- [MOCell](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/nsgaii/NSGAII.java)

- [SMS-EMOA](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/smsemoa/SMSEMOA.java)

これらはこのテンプレートに基づいている．

#### 進化戦略
EAのもう1つのサブfamilyは再生ステップにおいて突然変異のみを適用することに基づく進化戦略である．EAの対応する抽象クラスは[`AbstractEvolutionStragegy`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/algorithm/impl/AbstractEvolutionStrategy.java)である．

```java
package org.uma.jmetal.algorithm.impl;

/**
 * Created by ajnebro on 26/10/14.
 */
public abstract class AbstractEvolutionStrategy<S extends Solution<?>, Result> extends AbstractEvolutionaryAlgorithm<S, Result> {
  protected MutationOperator<S> mutationOperator ;
}
```

[PAES](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-algorithm/src/main/java/org/uma/jmetal/algorithm/multiobjective/paes/PAES.java) アルゴリズムはこのテンプレートに基づいている

TO BE COMPLETED
