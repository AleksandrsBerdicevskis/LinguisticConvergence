istart = ARGV[0].to_i
ifinish = istart + 49
ntokens = ARGV[1].to_i
nusers = ARGV[2]
ntexts = 6
dir = "Sets#{istart}"
vectorlen = ARGV[3]]

system "ruby test_extract_users.rb #{istart} #{ntokens} #{nusers}"
system "ruby test_mix_conllu_token.rb #{istart} #{ifinish} #{ntokens} #{ntexts} #{dir}"

res = File.open("test_results.tsv","w:utf-8")
res.puts "set_id\tntokens\tvectorlen\tspearman\tiqr_spearman\tpearson\tiqr_pearson\td\tiqrd"
res.close


#res.puts "#{dir}\t#{ntokens/3}\t#{vectorlen}"

ihash = {4500 => 10000, 9000 => 20000, 13500 => 30000, 18000 => 40000}
[4500,9000,13500,18000].each do |ntokens|
#[4500].each do |ntokens|
    istart = ihash[ntokens]
    ifinish = istart + 49
    dir = "Sets#{istart}"

    [150,300,450,600].each do |vectorlen|
#    [150].each do |vectorlen|
        STDERR.puts ntokens/3
        STDERR.puts vectorlen
        system "ruby test_delta.rb #{istart} #{ifinish} #{ntokens/3} #{dir} #{vectorlen}"
    end
end