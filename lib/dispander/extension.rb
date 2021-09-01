require "discorb"

module Dispander
  extend Discorb::Extension
  DISCORD_URL_PATTERN = /(?!<)https:\/\/(ptb.|canary.)?discord(app)?.com\/channels\/(?<guild>[0-9]{18})\/(?<channel>[0-9]{18})\/(?<message>[0-9]{18})(?!>)/

  event :message do |message|
    next if message.author.bot?

    Dispander.dispand(message)
  end

  event :reaction_add do |event|
    Dispander.delete_message(event)
  end

  class << self
    #
    # メッセージを解析して、埋め込みを送信します。
    #
    # @param [Discorb::Message] base_message 解析するメッセージ。
    #
    # @return [Array<Discorb::Message>] 埋め込みを送信したメッセージ。
    #
    def dispand(base_message)
      all_sent_messages = []
      base_message.content.scan(DISCORD_URL_PATTERN).each do |match|
        guild_id, channel_id, message_id = *match
        next unless base_message.guild.id == guild_id

        embeds = []

        sent_messages = []
        begin
          message = @client.guilds[guild_id].channels[channel_id].fetch_message(message_id).wait
        rescue Discorb::NotFoundError
          next
        else
          embed = create_embed_from_message(message)
          embeds << embed
          embeds += message.embeds
          embeds += message.attachments[1..]&.filter(&:image?)&.map { |attachment| create_embed_from_attachment(attachment) }.to_a

          until (embeds_send = embeds.slice!(..10)).empty?
            # @type [Array<Discorb::Message>]
            sent_messages << message.channel.post(embeds: embeds_send).wait
          end
          embed.url = "http://a.io/#{base_message.author.id}-#{message.author.id}-#{sent_messages.map(&:id).join(",")}"
          first_embeds = sent_messages[0].embeds
          first_embeds[0] = embed
          sent_messages[0].add_reaction(Discorb::UnicodeEmoji["wastebasket"])
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

    def delete_message(event)
      return unless event.emoji.name == "wastebasket"
      return if event.user_id == @client.user.id

      message = event.fetch_message.wait

      return if message.embeds.empty?
      return unless message.author == @client.user

      _, author_id, operator_id, sent_message_ids = *message.embed.url.match(/^http:\/\/a.io\/([0-9]+)-([0-9]+)-([0-9,]+)$/)
      return unless author_id == event.user_id || operator_id == event.user_id

      sent_message_ids.split(",").each do |sent_message_id|
        event.channel.delete_message!(sent_message_id).wait
      end
    end
  end
end
