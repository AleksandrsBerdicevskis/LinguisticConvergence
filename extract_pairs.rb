#update reading in corpus names

require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\date_tools.rb"
require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\corpus_tools.rb"
require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\file_tools.rb"





PATH = "C:\\Sasha\\D\\DGU\\CassandraMy\\SMCorpora\\"
PATH1 = "C:\\Sasha\\D\\DGU\\CassandraMy\\KorpApi\\"
PATH2 = "C:\\Sasha\\D\\DGU\\CassandraMy\\SocNetwork\\dist\\"
PATH3 = "C:\\Sasha\\D\\DGU\\CassandraMy\\Gramino\\GeneralStatsSumTokensUpdated\\"

corpus_label = ARGV[0]
maincorpus = get_maincorpus(corpus_label)
subforums = read_corpus_label(corpus_label)
filenames = []
subforums.each do |subforum|
    filenames << "#{PATH}#{subforum}_sentence.conllu"
end

if ARGV[1].nil?
    threshold = 6000
else
    threshold = ARGV[1].to_i/2
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
    post_interaction_threshold = ARGV[6].to_i
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



#=begin
tempfile = File.open("#{PATH2}#{corpus_label}\\prox_temp_values.txt","r:utf-8")
tf = tempfile.readlines
min_first_for_no = tf[0].to_i #fordon, sex: 1725
max_first_for_no = tf[1].to_i #fordon, sex: 8022
npairs = tf[2].to_i #fordon, sex: 37
last_int_for_no = tf[3].to_i

nsteps = 2
step = (max_first_for_no - min_first_for_no) / nsteps
nsteps = 1
#STDERR.puts step
accepted_nopairs = 0
###



int_file = File.open("#{PATH2}#{corpus_label}\\int_#{threshold*2}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_all.tsv","r:utf-8")
accepted_users = []
user_pairs = []

first_dates = {}
last_accepted_dates = {}
last_dates = {}
if no == ""
    STDERR.puts "Reading in users..."
    int_file.each_line.with_index do |line,index|
        if index > 0
            line1 = line.strip.split("\t")
            if line1[3] == "true"
                
                if !accepted_users.include?(line1[0])
                    accepted_users << line1[0]
                end
                if !accepted_users.include?(line1[1])
                    accepted_users << line1[1]
                end
                
                pair = [line1[0],line1[1]]
                user_pairs << pair
                first_dates[pair] = line1[4].to_i
                last_accepted_dates[pair] = line1[6].to_i
                last_dates[pair] = line1[7].to_i
            end
        end
    end
    int_file.close
elsif no == "no"
    
    
    #int_file = File.open("#{PATH2}#{corpus_label}\\#{no}int_#{threshold*2}_p3_t5_all.tsv","r:utf-8")
    #counter = 0
    int_file.each_line.with_index do |line,index|
        if index > 0
            #if counter >= npairs
            #    break
            #end
            #if rand(range) == 0
                line1 = line.strip.split("\t")
                if !accepted_users.include?(line1[0])
                    accepted_users << line1[0]
                end
                if !accepted_users.include?(line1[1])
                    accepted_users << line1[1]
                end
                
                pair = [line1[0],line1[1]]
                user_pairs << pair
                first_dates[pair] = min_first_for_no
                last_accepted_dates[pair] = min_first_for_no
                last_dates[pair] = last_int_for_no
                #counter += 1
            #end
        end
    end
end

STDERR.puts "Accepted pairs:",user_pairs.length
STDERR.puts "Accepted users:",accepted_users.length
#first_dates.each_pair do |pair,date|
#    STDOUT.puts "#{pair}\t#{date}\t#{last_dates[pair]}"
#end


word_threshold = 300
@wordlist = []
word_file = File.open("#{PATH3}#{maincorpus}_uncased.tsv","r:utf-8")
STDERR.puts "Reading in words..."
word_file.each_line.with_index do |line,index|
    if index > 0
        line1 = line.strip.split("\t")
        @wordlist << line1[0]
        if index >= word_threshold
            break
        end
    end
end 
STDERR.puts "Wordlist length:",@wordlist.length


@blacklist_before = Hash.new(0)
@blacklist_after = Hash.new{|hash, key| hash[key] = Array.new(2)}



def div_by_zero(a,b)
    if b != 0
        c = a.to_f/b
    else
        c = 0.0
    end 
    return c
end 

def check_user(user1,before_count_until,after_count_from,after_count_until,total_user,user_abs_freqs,threshold,date_mode)
    #STDOUT.puts user1 
    #STDOUT.puts "before_count_until", before_count_until
    #STDOUT.puts "after_count_from",after_count_from
    #STDOUT.puts "after_count_until",after_count_until

    user1_before = 0.0
    user1_after = 0.0
    abs_freqs_before = Hash.new(0.0)
    abs_freqs_after = Hash.new(0.0)
    rel_freqs_before = Hash.new(0.0)
    rel_freqs_after = Hash.new(0.0)
    
    passed_before = true
    passed_after = true
    
    dates = total_user.keys.sort
    if date_mode == "farthest"
        dates1 = dates.clone
        dates2 = dates.clone.reverse
    elsif date_mode == "closest"
        dates2 = dates.clone
        dates1 = dates.clone.reverse
    end


    dates1.each do |date|
        ntokens = total_user[date]
    #total_user.each_pair do |date,ntokens|
        if date < before_count_until
            if user1_before < threshold
                user1_before += ntokens
                @wordlist.each do |word|
                    abs_freqs_before[word] += user_abs_freqs[date][word]
                end
            else
                break
            end
        #else
            #break
        end
    end
    

    dates2.each do |date|
        ntokens = total_user[date]
    
        if date > after_count_from and date < after_count_until
            if user1_after < threshold
                user1_after += ntokens
                @wordlist.each do |word|
                    abs_freqs_after[word] += user_abs_freqs[date][word]
                end
            else
                break
            end
        #elsif date <= after_count_from
            #break
        end
    end
    
    #STDOUT.puts "before", user1_before
    #STDOUT.puts "after", user1_after
    if user1_before < threshold 
        passed_before = false
        #@blacklist_before[user1] = before_count_until
    end
    if user1_after < threshold 
        passed_after = false
        #@blacklist_after[user1] = [after_count_from,after_count_until]
    end
    #if passed
    @wordlist.each do |word|
        rel_freqs_before[word] =  abs_freqs_before[word]/user1_before
        rel_freqs_after[word] =  abs_freqs_after[word]/user1_after
    end
    #end

    return [passed_before,passed_after,rel_freqs_before,rel_freqs_after]
end



pairs_passed = Hash.new(false)
pairs_split = {}
pairs_stored_rels = Hash.new{|hash,key| hash[key] = Hash.new}
users_rel_freqs_before = {}
users_rel_freqs_after = {}

#calculate the cosine distance


abs_freqs = Hash.new{|hash, key| hash[key] = Hash.new{|hash1, key1| hash1[key1] = Hash.new{|hash2, key2| hash2[key2] = Hash.new(0.0)}}}
total = Hash.new{|hash, key| hash[key] = Hash.new{|hash1, key1| hash1[key1] = Hash.new(0.0)}}
    

if no == "no"
    tempfile2 = File.open("#{PATH2}#{corpus_label}\\prox_temp_values2.txt","r:utf-8")
    tf2 = tempfile2.readlines
    npairs = tf2[0].to_i

    user_pairs = user_pairs.sample(npairs * 50)
    accepted_users = user_pairs.flatten.uniq
    STDERR.puts "UPD!"
    STDERR.puts "Accepted pairs:",user_pairs.length
    STDERR.puts "Accepted users:",accepted_users.length

end


STDERR.puts "Going through texts..."
filelabels = []
filenames.each do |filename|
    STDERR.puts filename
    filelabel = filename.split("-")[1].split("_")[0]
    filelabels << filelabel
    f = File.open(filename,"r:utf-8")
    
    current_user = ""
    current_date = ""
    #current_sentence = []
    STDERR.puts "Reading the CONLLU..."
    f.each_line do |line|
        line1 = line.strip
        if line1 != ""
            if line1[0] != "#" and accepted_users.include?(current_user)
                word = line1.split("\t")[1].downcase
                if @wordlist.include?(word)
                    abs_freqs[filelabel][current_user][current_date][word] += 1 
                end
                total[filelabel][current_user][current_date] += 1
            else
                if line1.include?("# username")
                    current_user = line1.split(" = ")[1]
                #end
                elsif line1.include?("# post_date")
                    current_date = abs_day(date_to_array(line1.split("=")[1].strip.split(" ")[0],"-"))
                end
            end
        else
            
        end
    end
end




STDERR.puts "Going through the pairs..."
user_pairs.each.with_index do |pair, index|
    attempt_counter = 1
    STDERR.puts index
    user1 = pair[0]
    user2 = pair[1]
    before_count_until = first_dates[pair]
    after_count_from = last_accepted_dates[pair]
    if after_count_from == before_count_until 
        after_count_from += 1
    end
    after_count_until = last_dates[pair] + post_interaction_threshold

    begin
        STDERR.puts "Attempt #{attempt_counter}"         
        if no == "no"
            pair_checked = false
        else
            pair_checked = true
        end
        

        
        temp = Hash.new{|hash,key| hash[key] = Hash.new}

        if no == "no"
            filelabels.each do |filelabel|
                pair.each do |user|
                    temp[filelabel][user] = check_user(user, before_count_until + step * attempt_counter,after_count_from + step * attempt_counter,after_count_until,total[filelabel][user],abs_freqs[filelabel][user],threshold,date_mode)
                end
            end
        else
            filelabels.each do |filelabel|
                pair.each do |user|
                    temp[filelabel][user] = check_user(user, before_count_until,after_count_from,after_count_until,total[filelabel][user],abs_freqs[filelabel][user],threshold,date_mode)
                end
            end
 
        end

        filelabel1 = filelabels[0]
        filelabel2 = filelabels[1]
        if ((temp[filelabel1][user1][0] and temp[filelabel2][user2][0]) or (temp[filelabel2][user1][0] and temp[filelabel1][user2][0])) and ((temp[filelabel1][user1][1] and temp[filelabel2][user2][1]) or (temp[filelabel2][user1][1] and temp[filelabel1][user2][1]))
            pairs_passed[pair] = true
            pair_checked = true
            STDERR.puts "accepted"
            if no == "no"
                accepted_nopairs += 1
            end
            pairs_split[pair] = attempt_counter
            if (temp[filelabel1][user1][0] and temp[filelabel2][user2][0])
                pairs_stored_rels[pair][["before",filelabel1,user1]] = temp[filelabel1][user1][2]
                pairs_stored_rels[pair][["before",filelabel2,user2]] = temp[filelabel2][user2][2]
            end
            if (temp[filelabel2][user1][0] and temp[filelabel1][user2][0])
                pairs_stored_rels[pair][["before",filelabel2,user1]] = temp[filelabel2][user1][2]
                pairs_stored_rels[pair][["before",filelabel1,user2]] = temp[filelabel1][user2][2]
            end
            if (temp[filelabel1][user1][1] and temp[filelabel2][user2][1])
                pairs_stored_rels[pair][["after",filelabel1,user1]] = temp[filelabel1][user1][3]
                pairs_stored_rels[pair][["after",filelabel2,user2]] = temp[filelabel2][user2][3]
            end
            if (temp[filelabel2][user1][1] and temp[filelabel1][user2][1])
                pairs_stored_rels[pair][["after",filelabel2,user1]] = temp[filelabel2][user1][3]
                pairs_stored_rels[pair][["after",filelabel1,user2]] = temp[filelabel1][user2][3]
            end
        end
        attempt_counter += 1
        if attempt_counter > nsteps
            pair_checked = true
        end
    end until pair_checked == true
    if accepted_nopairs >= npairs * 5
        break
    end
end

STDERR.puts "#{pairs_passed.keys.length} pairs passed the threshold"
if no == ""
    tempfile2 = File.open("#{PATH2}#{corpus_label}\\prox_temp_values2.txt","w:utf-8")
    tempfile2.puts pairs_passed.keys.length
    tempfile2.close
end

STDERR.puts "Output..."
dirname = "pairs#{no}_#{threshold}_i#{interaction_threshold}_d#{date_mode[0]}"

if !Dir.exist?("#{PATH2}#{corpus_label}\\#{dirname}")
    Dir.mkdir("#{PATH2}#{corpus_label}\\#{dirname}")
end



filelabels.each do |filelabel|
    counter = 0
    #filelabel = filename.split("-")[1].split("_")[0]
    pairs_passed.each_pair do |pair,passed|
        if passed
            counter += 1
            pairs_stored_rels[pair].each_pair do |k,rel_freqs|
                
                o = File.open("#{PATH2}#{corpus_label}\\#{dirname}\\pair#{counter}_+_#{k[0]}_+_#{k[1]}_+_#{forbidden_symbol(k[2])}_+_#{pairs_split[pair]}.tsv","w:utf-8")
                
                user1 = pair[0]
                user2 = pair[1]
                o.puts "word\trel_freq"
                @wordlist.each do |word|
                    o.puts "#{word}\t#{rel_freqs[word]}"
                end
                o.close
            end
        end
    end
end
#=end
if no == ""
    system "ruby process_pairs.rb #{corpus_label} #{threshold} #{threshold_time_distance} #{threshold_post_distance} #{interaction_time_threshold} #{interaction_threshold} #{post_interaction_threshold} yes #{date_mode}"
elsif no == "no"
    system "ruby process_pairs.rb #{corpus_label} #{threshold} #{threshold_time_distance} #{threshold_post_distance} #{interaction_time_threshold} #{interaction_threshold} #{post_interaction_threshold} no #{date_mode}"

end
