

def extract_wordlist(path3,maincorpus,word_threshold)
    wordlist = []
    word_file = File.open("#{path3}#{maincorpus}_uncased.tsv","r:utf-8")
    STDERR.puts "Reading in words..."
    word_file.each_line.with_index do |line,index|
        if index > 0
            line1 = line.strip.split("\t")
            wordlist << line1[0]
            if index >= word_threshold
                break
            end
        end
    end
    return wordlist
end 