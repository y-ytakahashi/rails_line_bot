class Task < ApplicationRecord

    # task属性を定義
    attr :task

    # コンストラクタを実装
    def initialize(task)
        @task = task
    end

    # セッターを実装
    def task = (task)
        @task = task
    end

    #ゲッターを実装
    def task
        @task
    end

end
