

require_relative "C:\\Sasha\\D\\DGU\\Repos\\Cassandra\\date_tools.rb"
require_relative "C:\\Sasha\\D\\DGU\\Repos\\Cassandra\\corpus_tools.rb"

#change reading variable? (remove variable. Can be added separately)




corpus_label = ARGV[0]
forum = get_maincorpus(corpus_label)
STDERR.puts forum
subforums = read_corpus_label(corpus_label,"array")
STDERR.puts subforums
subforum1 = subforums[0].split("-")[1]
STDERR.puts subforum1
subforum2 = subforums[1].split("-")[1]
STDERR.puts subforum2
subforums = [subforum1,subforum2]
sflabel = corpus_label.split("-")[1]

if ARGV[1].nil?
    threshold = 12000
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

if ARGV[8].nil? or ARGV[8] != "false"
    nowrapper_mode = true
else
    nowrapper_mode = false
end

if ARGV[9].nil? or ARGV[9] == "farthest"
    date_mode = "farthest"
else
    date_mode = "closest"
end



if nowrapper_mode
    mode = "distance"
    with_variable = false
    
    def measure_interactions_in_thread(array, thread_id, proximity_hash)
        array2 = array.clone
        array.each do |user1|
            array2.shift
            
            array2.each do |user2|
                
                userlabel = [user1,user2].sort#.join("<===|===>")
                proximity_hash[userlabel] += 1
            end
        end
        end
    
    
    PATH2 = "C:\\Sasha\\D\\DGU\\CassandraMy\\SMCorpora\\"
    PATH1 = "C:\\Sasha\\D\\DGU\\CassandraMy\\KorpApi\\"
    
    
    STDERR.puts subforums.join(",")
    
    
    #variable = "kommer+inf"
    if !with_variable
        variable = "dist"
    end
    #vardir = "#{PATH1}variables\\#{variable}\\#{forum}\\#{sflabel}\\"
    #=begin
    if !Dir.exist?("#{variable}") 
            Dir.mkdir("#{variable}")
    end
    if !Dir.exist?("#{variable}\\#{forum}-#{sflabel}") 
        Dir.mkdir("#{variable}\\#{forum}-#{sflabel}")
    end
    
    
    #if !Dir.exist?("#{variable}\\#{forum}-#{sflabel}_anonymized") 
    #    Dir.mkdir("#{variable}\\#{forum}-#{sflabel}_anonymized")
    #end
    #=end
    
    
    hash_of_authoryear_hashes = Hash.new{|hash, key| hash[key] = Hash.new}
    #prolific_authors1 = []
    #prolific_authors2 = []
    authors_per_year = Hash.new{|hash, key| hash[key] = Hash.new(false)}
    
    authorcounter = 0
    anonymizer = {}
    
    
    def prolific_authors_from_subforums(forum,subforums,threshold)
        prolific_authors = []
        prolific_author_hash = Hash.new{|hash, key| hash[key] = Array.new}
        subforums.each do |subforum|
            authorfile = File.open("#{PATH1}authors\\#{forum}\\#{subforum}.tsv","r:utf-8")
            authorfile.each_line.with_index do |line, index|
                line2 = line.strip.split("\t")
                if index > 0
                    if line2.length == 2 #if there are no problems in the source file (e.g. empty nickname), otherwise ignore the line
                        if line2[1].to_i >= threshold 
                            if !(line2[0].include?("Anonym") and forum == "familjeliv")
                                #authorcounter += 1
                                nickname = line2[0]
                                nickname2 = nickname.gsub(" ","+%+")
                                
                                prolific_author_hash[subforum] << nickname # line2[1].to_i 
                                
                                
                                #nickname_anon = "user#{authorcounter}"
                                #anonymizer[nickname] = nickname_anon
            		        end
                        else
                            break
                        end
                    end
                end
            end
        end
        prolific_author_hash.each_pair do |subforum, authors|
            STDERR.puts subforum,authors.length,""
        end
    
        prolific_author_hash.values.flatten.uniq.each do |author|
            prolific = true
            prolific_author_hash.values.each do |subforum_authors| 
                if !subforum_authors.include?(author)
                    prolific = false
                    #STDERR.puts author
                    break
                end
            end
            if prolific
                prolific_authors << author
            end 
        end
        return prolific_authors
    end
    
    prolific_authors = prolific_authors_from_subforums(forum,subforums,threshold)
    STDERR.puts prolific_authors.length
    #STDOUT.puts prolific_authors
    #__END__
    
    #STDERR.puts prolific_authors
    
    hash_of_proximity_hashes = Hash.new{|hash, key| hash[key] = Hash.new(0)}
    hash_of_weight_hashes = {}
    proximity_hash = Hash.new(0)
    #current_interaction_date = {}
    #first_interaction_date = {}
    #accepted_interactions = Hash.new(0)
    #last_interaction_date = {}
    #passed_criteria = {}
    
    interactions = Hash.new{|hash,key| hash[key] = Hash.new{|hash1, key1| hash1[key1] = Array.new}}
    
    
    
    subforums.each do |subforum|
        f = File.open("#{PATH2}#{forum}-#{subforum}_post.conllu","r:utf-8")
        
        current_user = ""
        prev_thread = ""
        current_thread = ""
        users_in_thread = {}
        #post_in_thread = 0
        current_year = ""
        current_date = ""
        prev_year = ""
        prev_posts = []
    
        STDERR.puts subforum
        STDERR.puts "Reading file, building distance hashes..."
        f.each_line do |line|
            line1 = line.strip
            if line1 != ""
                #if line1[0] != "#"
                    #current_sentence << line1
                #else
                if line1.include?("# username")
                        
                        if !line1.split("=")[1].nil?
                            #post_in_thread += 1
                            current_user = line1.split("=")[1].strip
                            if mode == "distance"
                                prev_posts.each do |prev_post|
                                    if (abs_day(date_to_array(current_date, "-")) - abs_day(date_to_array(prev_post[1], "-")) <= threshold_time_distance) and (current_user != prev_post[0]) and prolific_authors.include?(current_user) and prolific_authors.include?(prev_post[0])
                                        userlabel = [current_user,prev_post[0]].sort
                                        proximity_hash[userlabel] += 1
                                        interactions[subforum][userlabel] << abs_day(date_to_array(current_date, "-"))
                                        
                                    end
                                end
                                    
                                if !(prev_posts.length < threshold_post_distance)
                                    prev_posts.shift
                                end
                                prev_posts << [current_user, current_date]
                            elsif mode == "thread_year"
                                if prolific_authors.include?(current_user)
                                    users_in_thread[current_user] = true
                                    authors_per_year[current_year][current_user] = true
                                end
                                
                            end
                        else
                            
                        end
    
                elsif line1.include?("# post_date")
                    
                    
                    
                    if mode == "thread_year"
                        current_year = line1.split("=")[1].strip.split("-")[0].to_i
                        if prev_year != current_year
                            if prev_year != ""
                                #STDERR.puts "thread spans more than one year"
                                measure_interactions_in_thread(users_in_thread.keys, prev_thread, hash_of_proximity_hashes[prev_year])
                                users_in_thread = {} #treated as different threads
                            end
                        end
                        prev_year = current_year
                    elsif mode == "distance"
                        current_date = line1.split("=")[1].strip.split(" ")[0]
                    end
                elsif line1.include?("# thread_id")
                    current_thread = line1.split("=")[1].strip
                    if current_thread != prev_thread
                        #STDERR.puts current_thread
                        if mode == "thread_year"
                            if prev_thread != ""
                                measure_interactions_in_thread(users_in_thread.keys, prev_thread, hash_of_proximity_hashes[current_year])
                                users_in_thread = {}
                                #post_in_thread = 0
                            end
                            prev_year = ""
                        elsif mode == "distance"
                            if prev_thread != ""
                                prev_posts = []
                            end
                        end
                        if prev_thread != ""
                            prev_thread = current_thread
                        end
                        
                    end
                end
                #end
            #else
                #distinguish between focus users, network users and message users
            end
        end
        if mode == "thread_year"
            measure_interactions_in_thread(users_in_thread.keys, current_thread, hash_of_proximity_hashes[current_year])
        end
    end
    year = "all"
    outtsv1 = File.open("#{variable}\\#{forum}-#{sflabel}\\int_#{threshold}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_#{year}.tsv", "w:utf-8")
    outtsv2 = File.open("#{variable}\\#{forum}-#{sflabel}\\noint_#{threshold}_p#{threshold_post_distance}_t#{threshold_time_distance}_i#{interaction_threshold}_#{year}.tsv", "w:utf-8")
    outtsv1.puts "first_user\tsecond_user\tinteractions\taccepted\tfirst_interaction\taccepted_interactions\tlast_accepted_interaction\tlast_interaction"
    outtsv2.puts "first_user\tsecond_user\tinteractions"
    
    passed_criteria = Hash.new{|hash,key| hash[key] = Hash.new}
    accepted_interactions = Hash.new{|hash,key| hash[key] = Hash.new(0)}
    last_accepted_interaction = Hash.new{|hash,key| hash[key] = Hash.new}
    
    min_first_for_no = 100000 #fordon, sex: 1725
    max_first_for_no = 0 #fordon, sex: 8022
    npairs = 0 #fordon, sex: 37
    passed_criteria_both = {}
    interactions.each_pair do |subforum,parray|
        parray.each_pair do |pair,iarray|
            if passed_criteria_both[pair] != false
                
                iarray.sort!
                first_int = 0
                
                iarray.each do |interactiondate|
                    if first_int == 0
                        accepted_interactions[subforum][pair] += 1
                        first_int = interactiondate
                        if first_int < min_first_for_no
                            min_first_for_no = first_int
                        end
                        if first_int > max_first_for_no
                            max_first_for_no = first_int
                        end
                    else
                        
                        if interactiondate - first_int <= interaction_time_threshold 
                            accepted_interactions[subforum][pair] += 1
                        else
                            passed_criteria[subforum][pair] = false
                            passed_criteria_both[pair] = false
                            break
                        end
                        if accepted_interactions[subforum][pair] == interaction_threshold and passed_criteria[subforum][pair] != false
                            passed_criteria[subforum][pair] = true
                            last_accepted_interaction[subforum][pair] = interactiondate
                            npairs += 1
                            break
                        end
                    end
                end
                if passed_criteria[subforum][pair] != true
                    passed_criteria_both[pair] = false
                end
            end
        end
    end
    
    proximity_hash.keys.each do |pair|
        if passed_criteria[subforum1][pair] and passed_criteria[subforum2][pair]
            passed_criteria_both[pair] = true
        end
    end

    #HERE
    last_interactions = []
    proximity_hash.each_pair do |pair,ninteractions|
        joint_interactions = [interactions[subforum1][pair],interactions[subforum2][pair]].flatten
        joint_last_accepted_interaction = [last_accepted_interaction[subforum1][pair].to_i,last_accepted_interaction[subforum2][pair].to_i].max
        joint_accepted_interactions = accepted_interactions[subforum1][pair] +  accepted_interactions[subforum2][pair]
        outtsv1.puts "#{pair[0]}\t#{pair[1]}\t#{ninteractions}\t#{passed_criteria_both[pair]}\t#{joint_interactions.min}\t#{joint_accepted_interactions}\t#{joint_last_accepted_interaction}\t#{joint_interactions.max}"
        last_interactions << joint_interactions.max
    end
    last_int_for_no = last_interactions.max
    
    tempfile = File.open("#{variable}\\#{forum}-#{sflabel}\\prox_temp_values.txt","w:utf-8")
    tempfile.puts min_first_for_no, max_first_for_no, npairs, last_int_for_no
    tempfile.close
    outtsv1.close
    
    counted = {}
    outtsv_array = []
    prolific_authors.each do |author1|
        prolific_authors.each do |author2|
            if author1 != author2 
                userlabel = [author1,author2].sort
                if  counted[userlabel].nil? and proximity_hash[userlabel] == 0
                    outtsv_array << "#{userlabel[0]}\t#{userlabel[1]}\t0"
                    counted[userlabel] = true
                end
            end
        end
    end
    
    outtsv2.puts outtsv_array.shuffle
    outtsv2.close
end


if no == "" or no == "both"
    system "ruby extract_pairs.rb #{corpus_label} #{threshold} #{threshold_time_distance} #{threshold_post_distance} #{interaction_time_threshold} #{interaction_threshold} #{post_interaction_threshold} yes #{date_mode}"
end

if no == "no" or no == "both"
    system "ruby extract_pairs.rb #{corpus_label} #{threshold} #{threshold_time_distance} #{threshold_post_distance} #{interaction_time_threshold} #{interaction_threshold} #{post_interaction_threshold} no #{date_mode}"
end