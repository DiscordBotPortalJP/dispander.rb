# dispander

discorbで出来たBotにメッセージ展開の機能を追加するExtension。
![画像](https://user-images.githubusercontent.com/59691627/131650571-ec50bf35-c971-4aeb-9a58-8fbf9b3e759b.png)


## インストール

Gemfileに以下を追記し...

```ruby
gem 'dispander'
```

これを実行してください。

    $ bundle install

または...

    $ gem install dispander

## 使い方

### Extensionとして読み込む

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

client.once :ready do
  puts <<~EOS
         ---------
         Logged in as #{client.user}(#{client.user.id})
         ---------
       EOS
end

client.extend(Dispander)

client.run ENV["DISCORD_BOT_TOKEN"]
```

### 手動で実行する

`Dispander.dispand`でメッセージを展開して、`Dispander.delete_message`で展開したメッセージを削除してください。

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

client.on :message do |message|
  next if message.author.bot?

  Dispander.dispand(message)
end

client.run ENV["DISCORD_BOT_TOKEN"]
```

## ライセンス

[MIT License](https://opensource.org/licenses/MIT)で公開しています。
