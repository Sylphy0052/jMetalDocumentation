# 測定

jMetal5の新機能は，実行中にアルゴリズム固有の情報を得ることを可能にする手段の組み込みである．現在の実装では，`PullMeasure`はオンデマンドの測定値(同期)を提供し，`PushMeasure`は測定の値を受け取るためにリスナー(オブザーバー)を登録することを可能にする(非同期)．

## 測定とは何か
測定は実行中のアルゴリズムの特定のプロパティにアクセスするように設計されている．例えば，遺伝子アルゴリズムにおける現在の母集団のサイズ，粒子軍最適化における粒子の現在の速度，現在の反復などを知ることができる．アルゴリズムが有することができる多くの特性を適切に処理するために，2つの措置が提供されている．

通常，プロパティは`getPopulationSize()`や`getCurrentIteration()`のようなgetterによってアクセスされる．これらのプロパティは同期的な方法でアクセスされる．つまり，ユーザーの要求に応じて取得及び処理を行う．この種の各プロパティは`PullMeasure.get()`メソッドに示すように，`PullMeasure`を通してアクセスすることができる．

```
public interface PullMeasure<Value> extends Measure<Value> {
	public Value get();
}
```

反対に，`PushMeasure`は非同期的な方法でプロパティの値を取得することを可能にする．つまり，値が生成時に提供され，その値がいつユーザに提供されるかを制御することができない．これは，ユーザが1つまたは複数の`MeasureListener`インスタンスを登録して，値が生成された時に値を受け取って処理するように，[Observerのデザインパターン](https://en.wikipedia.org/wiki/Observer_pattern)を使用することによって実現される．

```
public interface PushMeasure<Value> extends Measure<Value> {
	public void register(MeasureListener<Value> listener);
	public void unregister(MeasureListener<Value> listener);
}

public interface MeasureListener<Value> {
	public void measureGenerated(Value value);
}
```

`PullMeasure`はその値を代入する`set(value)`メソッドを提供せず，`PushMeasure`はある種の`push(value)`メソッドを提供しない．どちらもこれは，これらのインターフェースがアルゴリズムデザイナーの視点ではなく，ユーザの視点から設計されており，ユーザはこれらの値を書き込むことができない．デザーナーの方が難しくなると言えるかもしれないが，デザイナーは実際にどのような実装を使用するのかを正確に知る必要がある．それは値の提供方法を知っているからである．したがって，既存の実装を使用する場合は，この実装の特定のメソッドを知っている必要がある．’このメソッドには，値をset/pushするメソッドが含まれている．ユーザだけがこの測定で使用される特定の実装について知る必要はないので，Genericの`PullMeasure`と`PushMeasure`を扱わなければならない．これらのsetとpushの方法について考えるのは当然ですが，実際にはこれらの方法を実装する唯一の方法ではない．例えば，アルゴリズムデザイナーはプロパティの値を格納するフィールドを使用することができ，このプロパティ(および関連する`PullMeasure`)の更新はいくつかのメソッドの呼び出しではなく，この変数を通じて行われる．より詳細な説明は[*How to create measures?*](#how-to-create-measures)セクションで提供されている．

両方の測定インターフェースが`Measure`を拡張することに気づくことができる．これは空のインターフェースで`PullMeasure`と`PushMeasure`の両方に対するルートインターフェースとして使われます．これを持つことで，両方のタイプの測定値を別々に考慮する必要もなく，それらを一緒に保つために`Object`を使用する必要もなく，一般的な方法で測定値を管理するプログラマの可能性を与える．したがって，ここではjMetalのいくつかの非常に一般的なケースの対策の使用を簡素化するだけである．アルゴリズム設計者もユーザも通常はそれを必要としない．

また，測定に加えて、jMetal5は測定管理機能を扱う`MeasureManager`という概念も提供している．

```
public interface MeasureManager {
	public Collection<Object> getMeasureKeys();
	public <T> PullMeasure<T> getPullMeasure(Object key);
	public <T> PushMeasure<T> getPushMeasure(Object key);
}
```

`Measure`を返すジェネリックメソッドではなく，各タイプに対してメソッドを提供している．これは，前述したように，`Measure`インターフェースが空であるため，実用的価値がないからである．さらに，ユーザがメジャーを利用したい場合，測定とどのように対話するかを知るために，どの測定のタイプが実装されているかを知る必要がある．`Measure`を提供し，それを任意にキャストするのではなく，適切なタイプの測定を直接提供するメソッドを提供することを推奨した．測定インスタンスは両方のインターフェイスを実装できる（または同じプロパティに対して2つのインスタンスを使用可能にすることができる）ので，両方のメソッドが同じキーに対してインスタンスを返すことができ，一方向または別のものの使用をユーザーが選択できる．1つだけが提供されている場合（もう1つが`null`の場合），[`変換専用セクション`](#conversions-pullmeasure---pushmeasure)で説明しているように，それを完了することができる．このキーは，測定する特定のプロパティを識別し，アルゴリズムに依存し，ユーザがそれらを取得するための追加の`getMeasureKeys()`の存在を正当化する．

最後に，アルゴリズムが測定値を提供することを明示的に支持するためには，単に`MeasureManager`を提供する必要がある`Measurable`インターフェースを実装する必要がある．

```
public interface Measurable {
	public MeasureManager getMeasureManager();
}
```
これまで，`Algorithm`は`Measurable`を自動的に実装しないが，一般的な目的のためにインターフェースの関連性を評価すると将来のリリースで変更されるかもしれない．

`Measurable`インターフェースに直接そのメソッドを置くのではなく，`MeasureManager`の中間的概念を導入した．実際には構造家によってデザイナーは単にアルゴリズムの両方のインターフェースを実装し，単純に`this`を返すことによって`getMeasureManager()`を実装することで，中間的な概念を人為的に無視できることを示している．また，実際に`Measure`インターフェースに減らした場合，デザイナーは`Measurable`を実装する中間オブジェクト(MeasureManagerのメソッドなど)を追加してアルゴリズムように実装することもできるが，背景のオブジェクトにカスタムオブジェクトを使用する．技術的には，`MeasureManager`の中間概念を導入しても，最も単純な設計(中間概念なし)を使用していることを正当化する制約はない．とにかく，次の理由でこの設計を選択した．`MeasureManager`は対策マネジメント戦略に重点を置くべきだが，`Measurable`はどの対策を講じるべきかに焦点を当てるべきである．例えば，`MeasureManager`は測定インターフェースのうちの1つのみを実装する測定に対して，測定ごとに全ての特徴を持つために`PullMeasure/PushMeasure`を自動的にインスタンス化する高度な管理戦略を実装することができる．`PullMeasures`に対応する`PushMeasures`の検査管理を行う．一方，`Measurable`インスタンス(通常はアルゴリズム)は，提供する尺度を選択して供給することに重点を置き，尺度管理プロセスを専用の`MeasureManager`実装に委任する．

## なぜ測定を使用するのか
通常，プロパティは`getPopulationSize()`や`getCurrentIteration()`のようなgetterによってアクセスされる．この設計の利点は，これらのプロパティに簡単にアクセスできる．しかし，現在の反復のように，時間の経過と共に進化する特性を読みたい時に，この設計の限界に直面している．実際このような設計では，これらのプロパティを定期的に読み取り，頻繁に全ての更新(*polling*,*spinning*,*busy-waiting*とも呼ばれる)を確認することがある．このような設計は遺伝的アルゴリズムの所与の反復においてどの個体が生成されたかのように，短期間の値にアクセスしたい場合に特に煩雑になる．これらのIndividual(個人)は通常次の反復で忘れられる(良いものだけが保持される)．したがって，頻繁なチェックが必要である．実行時にそのようなプロパティにアクセスするには，いくつかの`getGeneratedIndividuals()`メソッドを継続的に調べたり，生成された全てのデータを格納するために多くの領域を消費したり，`getGeneratedIndividuals(int iteration)`メソッドにアクセスする．

jMetal5で選択する設計は，Measureの概念に基づいており，さらにMeasurementsという概念は`PullMeasure`と`PushMeasure`の2つのカテゴリに分かれている．最も単純なもの，`PullMeasure`はgetterから簡単にアクセスできる最初の種類のプロパティ用に設計されている．単純にgetterを使うことができるが，`PullMeasure`はプロパティへより一般的なアクセスを提供し，一般的な評価をアルゴリズムに適用することができる(一般的な実験ではjMetal5ではまだ実装されていない)．もう1つのタイプの測定である`PushMeasure`は他の種類のプロパティ用に設計されている．getterを使って簡単に管理することはできず，アルゴリズムによってリアルタイムに提供(push)する必要がある．このような尺度を使用することにより，値を受信して処理することができ，更新を緩和することなく，継続的にプロパティを検査する必要はない．

これらの両方の手段を持つもう1つの利点は，重要な追加のリソースを必要とせずに簡単にアルゴリズムに結合できることである．実際には，反復カウンタのようにアルゴリズムを使用するために値を変数に格納する必要がある場合，N回の反復の後，そのような値は`PullMeasure`によってカバー(置き換え)することができる．反対に，値が生成されているが，アルゴリズムの実行中に格納されていない場合，`PushMeasure`を使用して潜在的なリスナーに値をPushし，それを忘れて，リスナーがこの値を保存するかさらに処理する必要があるかどうかをリスナーが判断できるようにする．消費される追加リソースは次のとおりである．

- 格納された測定値は軽量であり，格納する解決策よりも少ないことが多い
- リスナーが登録されていない場合に無視される`PushMeasures`のリスナーへの呼び出し，そうでなければユーザによって完全に制御される(アルゴリズム設計者の先験的な決定ではない)．

## 測定の使い方は?
計測は特に使いやすいと定義されている．一方で`PullMeasure`は基本的にgetterのように扱うことができる．ここでは`getXxx()`を呼び出す代わりに`xxxMeasure.get()`を呼び出す．この結果，ユーザが必要とする時に直接`PullMeasure`を使用する．一方，`PushMeasure`はユーザにリスナーの登録と登録解除を許可するだけなので(通知生成はアルゴリズムの責任)，ユーザは処理がいつ行われるかを制御することができない．データが到着した時にデータを利用するためにプロセスをリスナーに配置するか，リスナーはその値を格納して処理する別のスレッドを置く必要がある．通知元(ここではアルゴリズム)がそのジョブを継続できるように，リスナーで費やされる時間を最小限に抑えることが一般的に推奨されている．

言い換えれば，`PullMeasures`を使用するプロセスは，一般に，アルゴリズムが実行された後に測定値が使用される形式を持つべきである．

```
Algorithm<?> algorithm = new MyAlgorithm();

/* retrieval of the measures */
/* (only if the algorithm implements Measurable) */
MeasureManager measures = algorithm.getMeasureManager();
PullMeasure<Object> pullMeasure = measures.getPullMeasure(key);
...

/* preparation of the run */
...
/* run the algorithm in parallel */
Thread thread = new Thread(algorithm);
thread.start();

/* user process */
while (thread.isAlive()) {
	...
	/* use the value */
	Object value = pullMeasure.get();
	...
}
```

反対に，`PushMeasures`を使用するプロセスは，一般的に，アルゴリズムを実行する前にプロセスが設定されているこの形式をとるべきである．

```
Algorithm<?> algorithm = new MyAlgorithm();

/* retrieval of the measures */
/* (only if the algorithm implements Measurable) */
MeasureManager measures = algorithm.getMeasureManager();
PushMeasure<Object> pushMeasure = measures.getPushMeasure(key);
pushMeasure.register(new MeasureListener<Object>() {

	@Override
	public void measureGenerated(Object value) {
		/* use the value */
		...
	}
});
...

/* preparation of the run */
...
/* run the algorithm in parallel */
Thread thread = new Thread(algorithm);
thread.start();

/* other processes */
while (thread.isAlive()) {
	...
}
```

`PushMeasures`だけが使用されている場合，`Thread`管理を全て削除して`algorithm.run()`を呼び出してそれが終了するのを待つこともできる．`PushMeasures`を介して設定された全てのプロセスが自動的に実行される．

## 測定の作成方法

### `PullMeasure`を生成する

通常，専用public fieldにいくつかの値を格納することによってアルゴリズムを実装するので，ユーザはそれらを即座に取得できる．一般的な例は，遺伝的アルゴリズムのように，複数のソリューションを同時に管理する多くのアルゴリズムで見つけることができるソリューションの集まりです．他の人は，`getPopulation()`のようなgetterを使って読み取り専用アクセスを提供することを好む(フィールドは外部ユーザによって変更できる)．これらのフィールドとgetterは簡単な方法でラップすることができるため，`PullMeasures`の最良の候補である．Population(人口)の例

```
PullMeasure<Collection<Path>> populationMeasure = new PullMeasure<Collection<Path>>() {

	@Override
	public String getName() {
		return "population";
	}

	@Override
	public String getDescription() {
		return "The set of paths used so far.";
	}

	@Override
	public Collection<Path> get() {
		return getPopulation();
	}
};
```

名前と説明は，計測自体を記述し，計測が何を提供しているかを知るための追加データであり，計測を実装する必要があるため，インターフェースの実装が非常の重くなる．しかし，このコードは`SimplePullMeasure`を使うことで減らすことができる．`SimplePullMeasure` は引数に名前と説明を取り，取り出したい値に注目する

```
PullMeasure<Collection<Path>> populationMeasure
= new SimplePullMeasure<Collection<Path>>("population",
                                          "The set of paths used so far.") {
	@Override
	public Collection<Path> get() {
		return getPopulation();
	}
};
```

getterが使用できない場合，フィールドも全く同じ方法で使用できる．これらのケースは`PullMeasure`の最も基本的な使い方である．jMetal形式を使用するように既存の実装を適合させる場合も，最も一般的である．実際，フィールドやgetterを使うことはアルゴリズムの内部データへのアクセスを提供する簡単な方法であり，`PullMeasure`を使う機会がたくさんある．しかし，これらのケースだけではない．確かに，計算は`get()`メソッドで定義することができる．これは存在しないフィールドやgetterに対しても新しい測定を追加することを可能にする．例えば，アルゴリズムがそのステップのいくつかで費やされた時間を管理すると仮定すると，アルゴリズムがいつ開始されたかを示す内部`startTime`値を格納することができる．この変数から，アルゴリズム実行時間を測定できる．

```
PullMeasure<Long> runningTimeMeasure
= new SimplePullMeasure<Long>("running time",
                              "The time spent so far in running the algorithm.") {
	@Override
	public Long get() {
		return System.currentTimeMillis() - startTime;
	}
};
```

計算を`get()`メソッドに直接入れることの利点は，値が要求された時にだけ計算されることである．したがって，それを計算する価値があるかどうかを判断するのは外部ユーザの責任である．

これまでのところ，`PullMeasure`はgetterと同じ方法で基本的に使用されることがわかった(getterを使用して計算を行うこともできる)．これは実際にその主要な目的だが，標準化された方法で行う．確かに，getterや同等のものを提供するアルゴリズムがあれば，それらを全て`PullMeasures`にラップすることができ，これは汎用コンテキストでこれらの値にアクセスする統一された方法を提供する(reflexionが使用されていない限り，使用する方法や使用方法がわからない場合)．さらに，`PullMeasures`のセットを提供するアルゴリズムがあれば，新しいインスタンスを作成することでインスタンスを拡張することができる(インスタンスにgetterやフィールドを追加することはできない)．

```
PullMeasure<Integer> populationSizeMeasure
= new SimplePullMeasure<Integer>("population size",
                                 "The number of solutions used so far.") {
	@Override
	public Integer get() {
		// reuse a measure to compute another property
		return populationMeasure.get().size();
	}
};
```

一連の尺度を拡張することができるため，例えば特定の実験のための特定の実験のための適切な尺度を作成することができる(まだjMetal5では実装されていない)．言い換えれば，アルゴリズム設計者は最小限の測定値を提供することに焦点を当て，必要に応じて外部ユーザに新しいものを定義させることができる．

最後に`PullMeasures`の作成を単純化するために，jMetalによって追加の機能が提供されている．`get()`メソッドの定義に焦点を当てた`SimplePullMeasure`をすでに述べたが，測定がフィールドをラップする場合，`BasicMeasure`を使用することで，フィールド自体の代わりに測定を直接使用することができ，それは追加の`set(value)`メソッドを定義することによって値を直接格納する．発生をカウントすることを可能にする`CountingMeasure`のように，より具体的な尺度も定義され，典型的には多数の反復または生成された多数の会のように，いくつかのアクティビティで費やされた時間を評価するために`DurationMeasure`を使用する．`PullMeasure`のいくつかの実装も`PushMeasure`を実装している．その使用に高い柔軟性を与えることができる．既存のアルゴリズムに`PullMeasures`を追加したい場合には，同時にいくつかの`PullMeasures`のインスタンス化を容易にするために，`MeasureFactory`を使うことも可能である．

- `createPullsFromFields(object)`: オブジェクトの各フィールドに対して`PullMeasure`をインスタンス化し，各フィールドの名前を対応する測定に関連づける`Map`を返す
- `createPullsFromGetters(object)`: 同様の方法で各getterの`PullMeasure`をインスタンス化する

### `PushMeasure`の生成
`PushMeasure`はアルゴリズムのための[Observerデザインパターン](https://en.wikipedia.org/wiki/Observer_pattern)を標準化する．オブザーバは観測値が更新された時に通知されるため，`PushMeasure`はアルゴリズムのプロパティが変更された時にリスナー(Javaのオブザーバ，特にSwing)に通知する．明らかにインターフェース`PushMeasure`は実際には減少している．リスなを追加したり削除したりするメソッドだけが必要である．そのため，リスナーに通知する方法を決定するのは，測定実装者の責任である．この作業を簡素化するため，いくつかの実装がすでにjMetalに用意されている．特に，新しい解決策がいつ生成されるかを通知したい場合など，大部分のケースではおそらく`SimplePushMeasure`の使用方法を見つけるだろう．

```
SimplePushMeasure<MySolution> lastGeneratedSolution = new SimplePushMeasure<>(
		"last solution",
		"The last solution generated during the running of the algorithm.");
```

受動的な`PullMeasure`(これはいつ呼び出すのか決めるユーザ)とは反対に，`PushMeasure`はアクティブな手段であり，通知プロセスを鳥がするアルゴリズムの実行中に発生する特定のイベントである．最後に生成されたソリューションの例については，ランダムな会から始まり，それを反復的に改良するための突然変異を作成する基本的な山登り法を持つことができる．これらのランダムおよび突然変異世代は，測定値を使用するためのアルゴリズムにおける2つの関連イベントである．

```
MySolution best = createRandomSolution();
lastGeneratedSolution.push(best);

while (running) {
	MySolution mutant = createMutantSolutionFrom(best);
	lastGeneratedSolution.push(mutant);

	// ...
	// remaining of the loop
	// ...
}
```

この例は2つの方法で説明されている．第一に，単一の尺度のために考慮すべきいくつかのイベントを有することができ，イベントが発生するとすぐに通知プロセスを完了させる必要がある．これは一般に，`PushMeasure`がアルゴリズム自体のコードに深く関与していることを意味し，フィールドまたはgetterメソッドをラップすることができる`PullMeasure`の反対側で，アルゴリズムそのものを手放す．さらに，このような関連イベントが発生するたびに，余分な計算時間が消費されることも意味する．そのための，`PushMeasure`はいくつかのプロパティを測定する唯一の目的のために余分なデータを計算するのではなく，すでに計算された結果について通知するのに適している(アルゴリズムが必要なため)．余分な計算のために，`PushMeasure`と`PushMeasure`の両方を利用する方が賢明であり，余分な計算の基礎となるすでに計算されたものについて(もしあれば)追加の`PullMeasure`を使って通知し，これはユーザによって要求された場合にのみ余分な計算を行う．

jMetalによって提供されるいくつかの実装は，すでに`PushMeasure`インターフェースを実装している．多くの場合には十分なはずの`SimplePushMeasure`がすでに見えたが，イベントをカウントできる`CountingMeasure`が通知されている(通知される値は通知ごとにインクリメントされる)．この実装は，反復の開始/終了，またはこれまでに生成された解決策の数を通知するのに適している．`PullMeasure`インターフェースも実装されており，必要に応じて通知された最後の値を取得できる．

### `PullMeasure`と`PushMeasure`の変換
いくつかの尺度は，`PullMeasure`と`PushMeasure`の両方を実装するが，単一の実装が実装されている場合，それを補完する別の尺度を作成することが可能である．これは双方向の変換を提供する`MeasureFactory`を使うことで実現できる．

- `createPullFromPush(push, initialValue)`は`PushMeasure`から`PullMeasure`を作成する．最初の`PushMeasure`がリスナーに通知するたびに`PullMeasure`が更新され，`get()`の将来の呼び出しのための値が保存される．メソッドに提供される`initialValue`は次の通知が発生する前にどの値を使用するかを指示する(通常はNullまたは実際の値)．
- `createPushFromPull(pull, period)`は`PullMeasure`から`PushMeasure`を作成する．`PullMeasure`によって生成される特別なイベントがないので，与えられた`period`で人為的にポーリング(値を頻繁にチェック)し，いつ変化するかを確認する．変更を特定すると，作成された`PushMeasure`から通知が生成される．短い`period`はより良い反応性を提供するが，計算コストを増加させ，なぜこの方法が必要でない限り使用されるべきではないかを説明する．これは`PullMeasure`ではなく，`PushMeasure`を設定することが一般的には選択可能であることが望ましいからである．その方向への変換コストはそれほど高くない．

### アルゴリズムに測定を追加
アルゴリズムが測定値を提供するためには，`Measurable`インターフェースを実装する必要がある．このインターフェースは`MeasureManager`を提供するように要求する．このマネージャはアルゴリズムの全ての測定へのアクセスを格納し，与えるものである．一方，独自のマネージャを実装することができるが，jMetalはすでに以下のメソッドを提供する`SimpleMeasureManager`実装を提供している．

```
public class SimpleMeasureManager implements MeasureManager {

	// Methods to configure the PullMeasures
	public void setPullMeasure(Object key, PullMeasure<?> measure) {...}
	public <T> PullMeasure<T> getPullMeasure(Object key) {...}
	public void removePullMeasure(Object key) {...}

	// Methods to configure the PushMeasures
	public void setPushMeasure(Object key, PushMeasure<?> measure) {...}
	public <T> PushMeasure<T> getPushMeasure(Object key) {...}
	public void removePushMeasure(Object key) {...}

	// Methods to configure any measure (auto-recognition of the type)
	public void setMeasure(Object key, Measure<?> measure) {...}
	public void removeMeasure(Object key) {...}
	public void setAllMeasures(Map<? extends Object, ? extends Measure<?>> measures) {...}
	public void removeAllMeasures(Iterable<? extends Object> keys) {...}

	// Provide the keys of the configured measures
	public Collection<Object> getMeasureKeys() {...}
}
```

タイプ固有の基本的なメソッドがあるが，提供される測定のタイプを自動的に認識し，対応するタイプ固有のメソッドを適用する汎用メソッドもある．`PullMeasure`と`PushMeasure`の両方を実装する測定も認識され，`PullMeasure`と`PushMeasure`の両方として追加されるので，同じ`key`で`getPullMeasure(key)`と`getPushMeasure(key)`を呼び出し，同じ尺度を返す．Genericメソッドは一度にいくつかのキーと測定を管理することで大規模な設定機能も提供する．

非jMetalアルゴリズムのインスタンスが提供されている場合，`MeasureFactory.createPullsFromFields(object)`と`MeasureFactory.createPullsFromGetters(object)`を使って簡単にいくつかの測定を取得することができる．これらの2つのメソッドによって返されたマップは，`SimpleMeasureManager.setAllMeasures(measure)`に提供され，実際のアルゴリズムについて何も知らずに，完全に機能し，`MeasureManager`を使用できるようになる．実行方法はわかっているので，[*How to use measures?*](#how-to-use-measures)説で説明しているように，専用のスレッドで実行することができる．アルゴリズムに関する情報を入手するための利用可能な手段である．しかし，[*Conversions `PullMeasure` <-> `PushMeasure`*](#conversions-pullmeasure---pushmeasure)節に書かれているように，`PullMeasures`から`PushMeasures`を作るのはコストがかかるが，逆はコストが安い．したがって，jMetalとは独立したアルゴリズムを単純に実装し，このプロシージャを使用して一連の`PullMeasures`を取得することができるが，jMetalの形式を使用する可能性のあるアルゴリズムを設計する人は，`PushMeasures`(または両方の組み合わせ)より多くの情報をより最適な方法で検索することができる．

[4.2 評価](evaluators.md)
