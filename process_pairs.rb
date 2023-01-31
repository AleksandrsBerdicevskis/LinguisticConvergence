require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\corpus_tools.rb"
require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\math_tools.rb"

corpus_label = ARGV[0]
subforums = read_corpus_label(corpus_label)
subforum1 = subforums[0].split("-")[1]
subforum2 = subforums[1].split("-")[1]
#stderr.puts subforum1, subforum2


if ARGV[1].nil?
    threshold = 6000
else
    threshold = ARGV[1].to_i
end

if ARGV[2].nil? 
    threshold_time_distance = 5
else
    threshold_time_distance = ARGV[2].to_i #days
end


if ARGV[3].nil?
    threshold_post_distance = 3
else
    threshold_post_distance = ARGV[3].to_i
end

if ARGV[4].nil?
    interaction_time_threshold = 365
else
    interaction_time_threshold = ARGV[4].to_i
end

if ARGV[5].nil?
    interaction_threshold = 5
else
    interaction_threshold = ARGV[5].to_i
end

if ARGV[6].nil?
    post_interaction_threshold = 366
else
    post_interaction_threshold = ARGV[6]
end

if ARGV[7].nil? or ARGV[7] == "yes"
    no = ""
else
    no = ARGV[7]
    if no != "no" and no != "both"
        no = ""
    end
end

if ARGV[8].nil? or ARGV[8] == "farthest"
    date_mode = "farthest"
else
    date_mode = "closest"
end



statuses = ["before","after"]
path = "dist\\#{corpus_label}\\pairs#{no}_#{threshold}_i#{interaction_threshold}_d#{date_mode[0]}"
STDERR.puts path

filenames = Dir.children(path)
#STDERR.puts "nfiles", filenames.length
o = File.open("dist\\#{corpus_label}\\distances#{no}_#{threshold}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_d#{date_mode[0]}.tsv","w:utf-8")
outline = "pair\tdistance_before\tdistance_after\tdiff\tnpositive"
if no == "no"
   outline << "\tsplitpoint"
end
o.puts outline

users = Hash.new{|hash,key| hash[key] = Array.new}
rel_freqs = Hash.new{|hash,key| hash[key] = Array.new}
pairs = []
splits = {}

filenames.each do |filename|
    
    ##stderr.puts filename
    fsplit = filename.split("_+_")
    pair = fsplit[0][4..-1]
    pairs << pair
    status = fsplit[1]
    subforum = fsplit[2]
    user = fsplit[3]
    if no == "no"
        splitpoint = fsplit[4].split(".")[0]
        splits[pair] = splitpoint
    end
    #STDOUT.puts filename, pair, status, subforum, user
    if !users[pair].include?(user)
        users[pair] << user
    end
    f = File.open("#{path}\\#{filename}","r:utf-8")
    f.each_line.with_index do |line,index|
        if index > 0
            rel_freqs[[pair,status,user,subforum]] << line.strip.split("\t")[1].to_f
        end
    end
end
#STDOUT.puts rel_freqs.keys[0]
#STDOUT.puts rel_freqs.values[0]
pairs.uniq!

diffs_total = 0.0
positive_total = 0.0

pairs.each do |pair|
    #STDERR.puts pair
    dists = {}
    statuses.each do |status|
        #STDERR.puts status
        #STDERR.puts pair
        users_pair = users[pair]
        #STDERR.puts 
        user1 = users_pair[0]
        user2 = users_pair[1]
        #STDERR.puts user1
        #STDERR.puts user2
        #STDERR.puts subforum1
        #STDERR.puts subforum2
        #STDERR.puts status
        #stderr.puts user1, user2
        #stderr.puts [pair,status,user1,subforum1].join(",")
        if !rel_freqs[[pair,status,user1,subforum1]].empty?
            #STDERR.puts rel_freqs[[pair,status,user1,subforum1]].join(" ")
            #STDERR.puts rel_freqs[[pair,status,user2,subforum2]].join(" ")
            dist1 = cosine_delta(rel_freqs[[pair,status,user1,subforum1]],rel_freqs[[pair,status,user2,subforum2]])
            #stderr.puts dist1
        end
        if !rel_freqs[[pair,status,user1,subforum2]].empty?
            dist2 = cosine_delta(rel_freqs[[pair,status,user1,subforum2]],rel_freqs[[pair,status,user2,subforum1]])
            #stderr.puts dist2
        end
        if dist1.nil?
            #stderr.puts 2
            dist = dist2
        elsif dist2.nil?
            #stderr.puts 1
            dist = dist1
        else
            #stderr.puts "both"
            dist = (dist1 + dist2)/2
        end
        #stderr.puts dist
        dists[status] = dist
    end
    outline = "#{pair}\t#{dists["before"]}\t#{dists["after"]}\t#{dists["before"]-dists["after"]}"
    diffs_total += dists["before"]-dists["after"]


    if dists["before"]-dists["after"] > 0
        outline << "\t1"
        positive_total += 1
    else
        outline << "\t0"
    end

    if no == "no"
        outline << "\t#{splits[pair]}"
    end
    o.puts outline
end

ave_diff = diffs_total/pairs.length
ave_positive = positive_total/pairs.length
if no == ""
    o2 = File.open("dist\\#{corpus_label}\\summary_#{threshold}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_d#{date_mode[0]}.tsv","w:utf-8")
    o2.puts "subforum1\tsubforum2\tmode\tnpairs\tave_diff\tpositive"
    o2.puts "#{subforum1}\t#{subforum2}\tact-int\t#{pairs.length}\t#{ave_diff}\t#{ave_positive}"
    o2.close
elsif no == "no"
    o2 = File.open("dist\\#{corpus_label}\\summary_#{threshold}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_d#{date_mode[0]}.tsv","a:utf-8")
    o2.puts "#{subforum1}\t#{subforum2}\tno-int\t#{pairs.length}\t#{ave_diff}\t#{ave_positive}"
    o2.close
end