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
    # @param [Discorb::Message] message 解析するメッセージ。
    #
    # @return [Array<Discorb::Message>] 埋め込みを送信したメッセージ。
    #
    def dispand(message)
      sent_messages = []
      message.content.scan(DISCORD_URL_PATTERN).each do |match|
        guild_id, channel_id, message_id = *match
        next unless message.channel.guild.id == guild_id

        embeds = []
        message = @client.guilds[guild_id].channels[channel_id].fetch_message(message_id).wait
        embed = create_embed_from_message(message)
        embeds << embed
        embeds += message.embeds
        embeds += message.attachments.map { |attachment| create_embed_from_attachment(attachment) }

        until (embeds_send = embeds.slice!(..10)).empty?
          sent_messages << message.channel.post(embeds: embeds_send).wait
        end
      end
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
      embed = Discorb::Embed.new
      if attachment.image?
        embed.image = Discorb::Embed::Image.new(
          attachment.url,
        )
      else
        embed.description = "[添付ファイル：#{attachment.filename}](#{attachment.url})"
      end
      embed

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
