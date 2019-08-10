# line-bot-api インポート
require 'line/bot'

class LineController < ApplicationController
    # Rails disable security

    protect_from_forgery :except => [:bot]

    def bot 
        # line で送られてきたメッセージデータを取得する
        body = request.body.read

        #line 以外からのアクセスの場合、エラーを返す
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
            head :bad_request
        end

        # Lineで送られてきたメッセージデータ eventsというデータ構造に変更
        events = client.parse_events_from(body)

        # events の中身をなめる
        events.each { |event|
            # eventがメッセージだったら
            case event 
            when Line::Bot::Event::Message
                # メッセージのタイプがテキストだったら（スタンプなどではなく）
                case event.type
                when Line::Bot::Event::MessageType::Text
                    #メッセージの文字列を取得して、変数taskに代入
                    task = event['message']['text']

                    #DBへの登録処理
                    begin
                        # メッセージの文字列をタスクテーブルに登録
                        Task.create!(task: task)
                        # 登録に成功した場合、登録した旨をLINEで返す
                        message = {
                            type: 'text',
                            text: "タスク「#{task}」を登録しました。！"
                        }

                        message2 = array('type'    => 'buttons',
                            'thumbnailImageUrl' => 'https://d1f5hsy4d47upe.cloudfront.net/79/79e452da8d3a9ccaf899814db5de9b76_t.jpeg',
                            'title'   => 'タイトル最大40文字' ,
                            'text'    => 'テキストメッセージ。タイトルがないときは最大160文字、タイトルがあるときは最大60文字',
                            'actions' => array(
                                           array('type'=>'message', 'label'=>'ラベルです', 'text'=>'アクションを実行した時に送信されるメッセージ' )
                                          )
                          );
          

                        client.reply_message(event['replyToken'],message)
                        client.reply_message(event['replyToken'],message2)

                    rescue
                        # 登録に失敗した場合、登録に失敗した旨をLINEで返す
                        message = {
                            type: 'text',
                            text: "タスク「#{task}」の登録に失敗しました。"
                        }
                        client.reply_message(event['replyToken'],message)
                    end
                end
            end
        }
        head :ok
    end

    #Lineボットを生成して返すプライベートメソッドの定義
    private 
    def client
        @client ||= Line::Bot::Client.new {|config|
            # サーバーに事前に登録したチャンネルシークレットとチャンネルトークンをセット
            config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
            config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end
end
