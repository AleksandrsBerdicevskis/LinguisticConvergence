require "Nokogiri"

filename = ARGV[0]
level = ARGV[1]
STDERR.puts filename

output = File.open("#{filename.split(".")[0]}.conllu","w:utf-8")

STDERR.puts "Parsing xml..."
#file = Nokogiri::XML(File.read(filename))
file = File.open(filename) { |f| Nokogiri::XML(f) }

STDERR.puts "Searching xml..."
subforums = file.css("forum").to_a
STDERR.puts "Converting..."
subforums.each do |subforum|
    subforum_title = subforum["title"].to_s.split(" > ")[1]
    subsubforum_title = subforum["title"].to_s.split(" > ")[-1]
    threads = subforum.css("thread").to_a
    threads.each do |thread|
        thread_id = thread["id"].to_s
        thread_title = thread["title"].to_s
        texts = thread.css("text").to_a
        texts.each do |text|
            text_id = text["id"].to_s
            text_date = text["date"].to_s
            username = text["username"].to_s
            if level == "post"
                output.puts "# subforum_id = #{subforum_title}"
                output.puts "# subsubforum_id = #{subsubforum_title}"
                output.puts "# thread_id = #{thread_id}"
                output.puts "# thread_title = #{thread_title}"
                output.puts "# post_id = #{text_id}"
                output.puts "# post_date = #{text_date}"
                output.puts "# username = #{username}"
                output.puts ""
            elsif level == "sentence"
                sentences = text.css("sentence").to_a
                sentences.each do |sentence|
                    sentence_id = sentence["id"].to_s
                    output.puts "# subforum_id = #{subforum_title}"
                    output.puts "# subsubforum_id = #{subsubforum_title}"
                    output.puts "# thread_id = #{thread_id}"
                    output.puts "# thread_title = #{thread_title}"
                    output.puts "# post_id = #{text_id}"
                    output.puts "# post_date = #{text_date}"
                    output.puts "# username = #{username}"
                    output.puts "# sent_id = #{sentence_id}"
                    words = sentence.css("token").to_a
                    words.each do |word|
                        id = word["ref"].to_i
                        form = word.text
                        lemma = word["lemma"].split("|")[1]
                        if lemma.nil?
                            lemma = form
                        end
                        upos = word["pos"] 
                        xpos = word["msd"] 
                        output.puts "#{id}\t#{form}\t#{lemma}\t#{upos}\t#{xpos}"
                    end
                    output.puts ""
                end
            end
        end
    end
end

output.close
STDERR.puts "Conversion done"