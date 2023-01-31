f = File.open("C:\\Sasha\\D\\DGU\\CassandraMy\\SMCorpora\\flashback-fordon_sentence.conllu","r:utf-8")
setindex = ARGV[0].to_i #1, 2, 3 osv
#sentencethreshold = ARGV[1].to_i #300, 600 etc.
tokenthreshold = ARGV[1].to_i #1500, 3000, 6000
userthreshold = ARGV[2].to_i #extract no more than n users 50
#nprolific_users = 0
prolific_users = []
users = Hash.new{|hash, key| hash[key] = Array.new}
tokens_per_user = Hash.new(0)


current_user = ""
current_sentence = []
f.each_line do |line|
    line1 = line.strip
    if line1 != ""
        if line1[0] != "#"
            if tokens_per_user[current_user] < tokenthreshold
                current_sentence << line1
                tokens_per_user[current_user] += 1
            end
        else
            if line1.include?("# username")
                current_user = line1.split(" = ")[1]
            end
        end
    else
        if !prolific_users.include?(current_user)
            users[current_user] << current_sentence
            if tokens_per_user[current_user] >= tokenthreshold #users[current_user].length >= sentencethreshold
                prolific_users << current_user
                STDERR.puts "#{prolific_users.length} prolific users found"
                if prolific_users.length >= userthreshold
                    break
                end
            end
        end
        current_sentence = []
    end
end

prolific_users.shuffle!

a = true
STDERR.puts "Printing..."
prolific_users.each.with_index do |user,index|
    if a
        letter = "A"
        index2 = index/2
    else
        letter = "B"
        index2 = (index+1)/2 - 1
    end
    o = File.open("Sets#{setindex}\\Set#{setindex+index2}Text#{letter}.conllu", "w:utf-8")
    users[user].each do |sentence|
        o.puts sentence
        o.puts ""
    end
    o.close
    a = !a
end