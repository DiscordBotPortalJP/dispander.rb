# dispander.rb

discorb で出来た Bot にメッセージ展開の機能を追加する Extension。
![画像](https://user-images.githubusercontent.com/59691627/131650571-ec50bf35-c971-4aeb-9a58-8fbf9b3e759b.png)

[DiscordBotPortalJP/dispander](https://github.com/DiscordBotPortalJP/dispander) の Ruby 版。

## インストール

Gemfile に以下を追記し...

```ruby
gem 'dispander'
```

これを実行してください。

    $ bundle install

または...

    $ gem install dispander

## 使い方

### Extension として読み込む

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

client.load_extension(Dispander::Core)

client.run ENV["DISCORD_BOT_TOKEN"]
```

### 手動で実行する

`Dispander::Core#dispand`でメッセージを展開、`Dispander::Core#delete_message`で展開したメッセージを削除できます。

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

dispander = Dispander::Core.new(client)

client.on :message do |message|
  next if message.author.bot?

  dispander.dispand(message)
end

client.on :reaction_add do |event|
  dispander.delete_message(event)
end

client.run ENV["DISCORD_BOT_TOKEN"]
```

### 削除の絵文字を変更する

`Dispander#delete_emoji`に絵文字を指定するか、`Client#load_extension`に引数として追加してください。

```ruby
client.load_extension(Dispander::Core, delete_emoji: Discorb::UnicodeEmoji["x"])
```

### 展開条件を変更する

`Dispander#should_expand?`をオーバーライドしてください。

```ruby
dispander = Dispander::Core.new(client)

def dispander.should_expand?(base_message, ids)
  ENV["ALLOWED_GUILDS"].split(",").include?(ids[0])
end

client.load_extension(dispander)
```

## ライセンス

[MIT License](https://opensource.org/licenses/MIT)で公開しています。
