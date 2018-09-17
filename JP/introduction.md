<!--<div id='introduccion'/>-->

## はじめに

jMetalプロジェクトはメタヒューリスティックを備えた，使いやすく，柔軟で拡張性があり，ポータブルな多目的最適化フレームワークを必要と認め，2006年に開始された．2008年以降， http://jmetal.sourceforge.net でホストされている．2014年以降， https://github.com/jMetal/jMetal で開発されている．

jMetalの最初のリリースから9年が経過したのち，2014年にソフトウェアの大幅な再設計が行われた．アイディアは次の通りである．

- アーキテクチャは同じ機能を維持しながらシンプルなデザインを提供する
- Mavenは開発，テスト，パッケージング，デプロイメントのツールとして使用される
- アルゴリズムテンプレートを提供することでコードの再利用の促進
- コード品質の向上
  - 単体テストの応用
  - Javaの機能(ジェネリックなど)の使い方の改善
  - デザインパターン(singleton, builder, factory, observer)の使用
  - クリーンコードガイドラインの適用「Clean code: A Handbook of Agile Software Craftsmanship」(Robert C.Martin)
- 並列処理のサポート
- 実行時にアルゴリズムの情報を取得する手段の紹介

その結果，jMetal5と呼び，「Redesigning the jMetal Multi-Objective Optimization Framework. Antonio J. Nebro, Juan J. Durillo, Matthieu Vergne. GECCO (Companion) 2015」の論文に記載された．DOI: http://dx.doi.org/10.1145/2739482.2768462

[2.インストール](installation.md)
