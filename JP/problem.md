## `Problem`インターフェース
jMetalにProblemを含めるには，`Problem`インターフェースを実装する必要がある．

```java
package org.uma.jmetal.problem;

/**
 * Interface representing a multi-objective optimization problem
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 *
 * @param <S> Encoding
 */
public interface Problem<S extends Solution<?>> extends Serializable {
  /* Getters */
  public int getNumberOfVariables() ;
  public int getNumberOfObjectives() ;
  public int getNumberOfConstraints() ;
  public String getName() ;

  /* Methods */
  public void evaluate(S solution) ;
  public S createSolution() ;
```

全ての問題は決定変数の数，目的関数の数及び制約の数によって特徴付けられるため，それらの値を返すためのGetterメソッドを定義する必要がある．遺伝型`S`は，問題の解の符号化を決定することを可能にする．このように，問題にはクラス`S`の任意の解を評価する方法と，新しい解を作成するための`createSolution()`メソッドを提供する必要がある．

`Solution`インターフェースは汎用的なものであるため，jMetal5にはDouble(連続的な)問題やバイナリ問題などを表現するためにいくつかのインターフェースがある．このように[`DoubleProblem`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/problem/DoubleProblem.java)インターフェースは以下のように定義されている．

```java
package org.uma.jmetal.problem;

/**
 * Interface representing continuous problems
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 */
public interface DoubleProblem extends Problem<DoubleSolution> {
  Double getLowerBound(int index) ;
  Double getUpperBound(int index) ;
}
```

`DoubleProblem`を実装する際の問題は，`DoubleSolution`オブジェクトだけを受け付け，各変数の上限と下限を得るメソッドを実装する必要がある．jMetal5は[`AbstractDoubleProblem`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/problem/impl/AbstractDoubleProblem.java)と呼ばれる`DoubleProblem`を実装するデフォルト抽象クラスを提供する．

```java
package org.uma.jmetal.problem.impl;

public abstract class AbstractDoubleProblem extends AbstractGenericProblem<DoubleSolution>
  implements DoubleProblem {

  private List<Double> lowerLimit ;
  private List<Double> upperLimit ;

  /* Getters */
  @Override
  public Double getUpperBound(int index) {
    return upperLimit.get(index);
  }

  @Override
  public Double getLowerBound(int index) {
    return lowerLimit.get(index);
  }

  /* Setters */
  protected void setLowerLimit(List<Double> lowerLimit) {
    this.lowerLimit = lowerLimit;
  }

  protected void setUpperLimit(List<Double> upperLimit) {
    this.upperLimit = upperLimit;
  }

  @Override
  public DoubleSolution createSolution() {
    return new DefaultDoubleSolution(this)  ;
  }
}
```

Double Problemの例として，次に既知の[`Kursawe`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-problem/src/main/java/org/uma/jmetal/problem/multiobjective/Kursawe.java)の実装を含める．

```java
package org.uma.jmetal.problem.multiobjective;

/**
 * Class representing problem Kursawe
 */
public class Kursawe extends AbstractDoubleProblem {

  /**
   * Constructor.
   * Creates a default instance of the Kursawe problem.
   */
  public Kursawe() {
    // 3 variables by default
    this(3);
  }

  /**
   * Constructor.
   * Creates a new instance of the Kursawe problem.
   *
   * @param numberOfVariables Number of variables of the problem
   */
  public Kursawe(Integer numberOfVariables) {
    setNumberOfVariables(numberOfVariables);
    setNumberOfObjectives(2);
    setName("Kursawe");

    List<Double> lowerLimit = new ArrayList<>(getNumberOfVariables()) ;
    List<Double> upperLimit = new ArrayList<>(getNumberOfVariables()) ;

    for (int i = 0; i < getNumberOfVariables(); i++) {
      lowerLimit.add(-5.0);
      upperLimit.add(5.0);
    }

    setLowerLimit(lowerLimit);
    setUpperLimit(upperLimit);
  }

  /** Evaluate() method */
  public void evaluate(DoubleSolution solution){
    double aux, xi, xj;
    double[] fx = new double[getNumberOfObjectives()];
    double[] x = new double[getNumberOfVariables()];
    for (int i = 0; i < solution.getNumberOfVariables(); i++) {
      x[i] = solution.getVariableValue(i) ;
    }

    fx[0] = 0.0;
    for (int var = 0; var < solution.getNumberOfVariables() - 1; var++) {
      xi = x[var] * x[var];
      xj = x[var + 1] * x[var + 1];
      aux = (-0.2) * Math.sqrt(xi + xj);
      fx[0] += (-10.0) * Math.exp(aux);
    }

    fx[1] = 0.0;

    for (int var = 0; var < solution.getNumberOfVariables(); var++) {
      fx[1] += Math.pow(Math.abs(x[var]), 0.8) +
        5.0 * Math.sin(Math.pow(x[var], 3.0));
    }

    solution.setObjective(0, fx[0]);
    solution.setObjective(1, fx[1]);
  }
}
```

`DoubleProblem`インターフェースと`AbstractDoubleProblem`と同様に，`BinaryProblem`と`AbstractBinaryProblem`，`IntegerProblem`と`AbstractIntegerProblem`などがある．問題の定義と実装に関連するパッケージは次のとおりである．

- [`org.uma.jmetal.problem` (module `jmetal-core`)](https://github.com/jMetal/jMetal/tree/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/problem): Interface定義.
- [`org.uma.jmetal.problem.impl` (module `jmetal-core`)](https://github.com/jMetal/jMetal/tree/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/problem/impl): デフォルトの実装.
- [`org.uma.jmetal.problem` (module `jmetal-problem`)](https://github.com/jMetal/jMetal/tree/jmetal-5.0/jmetal-problem/src/main/java/org/uma/jmetal/problem): 実装された問題.

### 制約された問題
jMetal5で制約された問題を処理するには，2つの方法がある．最初の選択は，`evaluate()`メソッドで制約違反を処理するコードを含めることである．2番目の選択は制約を評価するためのメソッドを含む[`ConstrainedProblem`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-core/src/main/java/org/uma/jmetal/problem/ConstrainedProblem.java)インターフェースを実装することである．

```java
package org.uma.jmetal.problem;

/**
 * Interface representing problems having constraints
 *
 * @author Antonio J. Nebro <antonio@lcc.uma.es>
 */
public interface ConstrainedProblem<S extends Solution<?>> extends Problem<S> {

 /* Getters */
  public int getNumberOfConstraints() ;

  /* Methods */
  public void evaluateConstraints(S solution) ;
}
```

jMetal5ではデフォルトのアプローチは２番目のアプローチである．次のコードには，[`Tanaka`](https://github.com/jMetal/jMetal/blob/jmetal-5.0/jmetal-problem/src/main/java/org/uma/jmetal/problem/multiobjective/Tanaka.java)問題の実装が含まれている．これには2つの制約がある．

```java
package org.uma.jmetal.problem.multiobjective;

/**
 * Class representing problem Tanaka
 */
public class Tanaka extends AbstractDoubleProblem implements ConstrainedProblem<DoubleSolution> {
  public OverallConstraintViolation<DoubleSolution> overallConstraintViolationDegree ;
  public NumberOfViolatedConstraints<DoubleSolution> numberOfViolatedConstraints ;

  /**
   * Constructor.
   * Creates a default instance of the problem Tanaka
   */
  public Tanaka() {
    setNumberOfVariables(2);
    setNumberOfObjectives(2);
    setNumberOfConstraints(2);
    setName("Tanaka") ;

    List<Double> lowerLimit = new ArrayList<>(getNumberOfVariables()) ;
    List<Double> upperLimit = new ArrayList<>(getNumberOfVariables()) ;

    for (int i = 0; i < getNumberOfVariables(); i++) {
      lowerLimit.add(10e-5);
      upperLimit.add(Math.PI);
    }

    setLowerLimit(lowerLimit);
    setUpperLimit(upperLimit);

    overallConstraintViolationDegree = new OverallConstraintViolation<DoubleSolution>() ;
    numberOfViolatedConstraints = new NumberOfViolatedConstraints<DoubleSolution>() ;
  }

  @Override
  public void evaluate(DoubleSolution solution)  {
    solution.setObjective(0, solution.getVariableValue(0));
    solution.setObjective(1, solution.getVariableValue(1));
  }

  /** EvaluateConstraints() method */
  @Override
  public void evaluateConstraints(DoubleSolution solution)  {
    double[] constraint = new double[this.getNumberOfConstraints()];

    double x1 = solution.getVariableValue(0) ;
    double x2 = solution.getVariableValue(1) ;

    constraint[0] = (x1 * x1 + x2 * x2 - 1.0 - 0.1 * Math.cos(16.0 * Math.atan(x1 / x2)));
    constraint[1] = -2.0 * ((x1 - 0.5) * (x1 - 0.5) + (x2 - 0.5) * (x2 - 0.5) - 0.5);

    double overallConstraintViolation = 0.0;
    int violatedConstraints = 0;
    for (int i = 0; i < getNumberOfConstraints(); i++) {
      if (constraint[i]<0.0){
        overallConstraintViolation+=constraint[i];
        violatedConstraints++;
      }
    }

    overallConstraintViolationDegree.setAttribute(solution, overallConstraintViolation);
    numberOfViolatedConstraints.setAttribute(solution, violatedConstraints);
  }
}

```

### Discusion
`ConstrainedProblem`インターフェースを組み込むことは，全ての問題が`evaluate()`と`evalutateConstraints()`メソッドを持っていた以前のjMetalバージョンによって動機付けられた．制限されていない問題の場合，`evaluateConstraints()`は空のメソッドとして実装された．[`インターフェース分離原理(Interface Principle)`](https://en.wikipedia.org/wiki/Interface_segregation_principle)のこの違反を回避するために，サイドメトリック制約(side constraints)を有する問題のみが制約を評価する必要がある．

元のjMetalでは，解決策を評価するには2つの文が必要である．

```java
Problem problem ;
Solution solution ;
...
problem.evaluate(solution) ;
problem.evaluateContraints(solution) ;
```

問題に制約があるかどうかを判断するためのチェックが含まれていなければならない．

```java
DoubleProblem problem ;
DoubleSolution solution ;

problem.evaluate(solution);
if (problem instanceof ConstrainedProblem) {
  ((ConstrainedProblem<DoubleSolution>) problem).evaluateConstraints(solutionn);
}
```

[3.4 アルゴリズムインターフェース](algorithm.md)
