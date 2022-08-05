require "discorb"

module Dispander
  class Core
    include Discorb::Extension

    @@discord_url_pattern = /(?!<)https:\/\/(ptb.|canary.)?discord(app)?.com\/channels\/(?<guild>[0-9]{17,})\/(?<channel>[0-9]{17,})\/(?<message>[0-9]{17,})(?!>)/

    def initialize(client, delete_emoji: Discorb::UnicodeEmoji["wastebasket"])
      @delete_emoji = delete_emoji
      super(client)
    end

    event :message do |message|
      next if message.author.bot?

      dispand(message)
    end

    event :reaction_add do |event|
      delete_message(event)
    end

    # @return [Discorb::Emoji] 削除リアクションとして使う絵文字。
    attr_accessor :delete_emoji

    #
    # メッセージを解析して、埋め込みを送信します。
    #
    # @param [Discorb::Message] base_message 解析するメッセージ。
    #
    # @return [Array<Discorb::Message>] 埋め込みを送信したメッセージ。
    #
    def dispand(base_message)
      all_sent_messages = []
      base_message.content.scan(@@discord_url_pattern).each do |match|
        guild_id, channel_id, message_id = *match
        next unless should_expand?(base_message, [guild_id, channel_id, message_id])

        embeds = []

        sent_messages = []
        begin
          next unless guild = @client.guilds[guild_id]
          next unless channel = guild.channels[channel_id] || @client.fetch_channel(channel_id).wait
          next unless message = channel.fetch_message(message_id).wait
        rescue Discorb::NotFoundError, NoMethodError
          next
        else
          embed = create_embed_from_message(message)
          embeds << embed
          embeds += message.embeds
          embeds += message.attachments[1..]&.filter(&:image?)&.map { |attachment| create_embed_from_attachment(attachment) }.to_a

          until (embeds_send = embeds.slice!(..10)).empty?
            sent_messages << base_message.channel.post(embeds: embeds_send).wait
          end
          embed.url = "http://a.io/#{base_message.author.id}-#{message.author.id}-#{sent_messages.map(&:id).join(",")}"
          first_embeds = sent_messages[0].embeds
          first_embeds[0] = embed
          sent_messages[0].add_reaction(@delete_emoji)
          sent_messages[0].edit(embeds: first_embeds).wait
          all_sent_messages += sent_messages
        end
      end
      all_sent_messages
    end

    #
    # メッセージから埋め込みを作成します。
    #
    # @param [Discorb::Message] message 埋め込みを作成するメッセージ。
    #
    # @return [Discorb::Embed] 埋め込み。
    #
    def create_embed_from_message(message)
      embed = Discorb::Embed.new
      embed.description = message.content
      embed.timestamp = message.timestamp
      embed.author = Discorb::Embed::Author.new(
        message.author.to_s,
        icon: message.author.avatar.url,
      )
      embed.footer = Discorb::Embed::Footer.new(
        "#" + message.channel.name
      )
      if (attachment = message.attachments[0]) && attachment.image?
        embed.image = attachment.proxy_url
      end
      embed
    end

    #
    # 添付ファイルから埋め込みを作成します。
    #
    # @param [Discorb::Attachment] attachment 埋め込みを作成する添付ファイル。
    #
    # @return [Discorb::Embed] 埋め込み。
    #
    def create_embed_from_attachment(attachment)
      embed = Discorb::Embed.new(
        image: attachment.proxy_url,
      )
      embed
    end

    #
    # 埋め込みを削除します。
    #
    # @param [Discorb::Gateway::ReactionEvent] event リアクションのイベント。
    #
    def delete_message(event)
      return unless event.emoji == @delete_emoji
      return if event.user_id == @client.user.id

      message = event.fetch_message.wait

      return if message.embeds.empty?
      return unless message.author == @client.user

      _, author_id, operator_id, sent_message_ids = *message.embed.url.match(/^http:\/\/a.io\/([0-9]+)-([0-9]+)-([0-9,]+)$/)
      return unless author_id == event.user_id || operator_id == event.user_id

      sent_message_ids.split(",").each do |sent_message_id|
        event.channel.delete_message(sent_message_id).wait
      end
    end

    #
    # メッセージを展開するかどうか。
    # デフォルトでは同じサーバーのみ展開されます。
    # このメソッドをオーバーライドすることにより、条件を変更することができます。
    #
    # @params [Discorb::Message] base_message 展開するメッセージ。
    # @params [Array<String>] match 展開するメッセージのID。`[guild_id, channel_id, message_id]`
    #
    # @return [Boolean] 展開する場合は `true`、展開しない場合は `false`。
    #
    def should_expand?(base_message, ids)
      base_message.guild.id == ids[0]
    end
  end
end
