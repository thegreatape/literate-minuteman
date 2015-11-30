require 'rspec/core/formatters/base_text_formatter'

class CustomFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :example_failed

  BLOCK_START_RE = /(^|\s)do(\s|$)/
  BLOCK_END_RE = /(^|\s)end(\s|$)/

  def initialize(output)
    @output = output
  end

  def example_failed(notification)
    file, line_num = notification.example.location.split(':')
    start_line = line_num.to_i - 1

    lines = File.readlines(file)
    current_line = start_line
    block_count = BLOCK_START_RE.match(lines[current_line]) ? 1 : 0
    while block_count >= 1
      current_line += 1
      if lines[current_line] =~ BLOCK_START_RE
        block_count += 1
      elsif lines[current_line] =~ BLOCK_END_RE
        block_count -= 1
      end
    end

    repo = Rugged::Repository.new(Rails.root.to_s)
    blame = Rugged::Blame.new(repo, file.sub(/^\.\//, ''))
    authors = {}
    (start_line..current_line).each do |line|
      blame_line = blame.for_line(line)
      authors[blame_line[:orig_signature][:name]] ||= 0
      authors[blame_line[:orig_signature][:name]] += 1
    end

    @output << "failure from #{start_line} to #{current_line}:\n"
    @output << "hm, we should probably bug "
    @output << authors.map {|name, score| "#{name} (#{score})"}.to_sentence

    users = {
      'Thomas Mayfield' => '@thomas'
    }
    webhook_url = "https://hooks.slack.com/services/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"
    authors.each do |author, score|
      if users[author]
        message = "Hey, a test just failed on master in `#{file}` that it looks like you might know something about:
        ```
        #{(start_line..current_line+1).map {|l| lines[l-1]}.join}
        ```
        "
        Slack::Notifier.new(webhook_url, username: "Flaky Test Notifier", channel: users[author]).ping(message)
      end
    end
  end
end
