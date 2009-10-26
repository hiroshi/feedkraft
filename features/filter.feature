feature: フィルター

  Scenario: トップページから新規フィルター画面へ
    Given "トップ"ページを表示している
    When "url"に"test/fixtures/files/yakitara.atom"と入力する
    And "new"ボタンをクリックする
    Then "新規フィルター"ページを表示していること

  Scenario: フィルター条件を更新してプレビュー
    Given "新規フィルター"ページをパラメータ"url=test/fixtures/files/yakitara.atom"で表示している
    When "filter_key_0"から"&lt;category term&gt;"を選択する
    And "filter_value_0"に"Rails"と入力する
# preview ボタンは javascript を実行するので selenium でないとダメだ
    And "preview"ボタンをクリックする
#    Then show me the page
#    Then "Filtered (9 entries)"と表示されていること

#   Scenario: ログインせずに新規フィルター
#     Given "新規フィルター"ページ
#     And "create"ボタンは存在しないこと
#     And "login to create filters"と表示されていること
