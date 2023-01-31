forumname = ARGV[0]
if ARGV[1].nil? 
    STDERR.puts "You didn't specify the type: post or sentence!"
    exit
end

f = File.open("#{ARGV[0]}.xml","r:utf-8")
unitlist = ["paragraph", "text", "thread", "forum", "corpus"]
shortunitlist = ["paragraph", "text", "thread"]
open = Hash.new("")
nsents = 0
filecounter = 1
o = File.open("#{ARGV[0]}#{filecounter}.xml","w:utf-8")
f.each_line do |line|
    unitlist.each do |unit|
        if line.strip.split(" ")[0] == "<#{unit}"
            open[unit] = line
        elsif line.strip == "</#{unit}>"
            open[unit] = ""
        end
    end
    if line.strip == "</sentence>"
        nsents += 1
    end
    o.puts line.strip
    if nsents > 100000 and (open["paragraph"] == "" and open["text"] == "" and open["thread"] == "")
        
        unitlist.each do |unit|
            if open[unit] != ""
                o.puts "</#{unit}>"
            end
        end
        o.close
        system("ruby xml_to_conllu_sm.rb #{ARGV[0]}#{filecounter}.xml #{ARGV[1]}")
        File.delete("#{ARGV[0]}#{filecounter}.xml")
        nsents = 0
        #open = {}
        filecounter += 1
        o = File.open("#{ARGV[0]}#{filecounter}.xml","w:utf-8")
        ["corpus", "forum"].each do |unit|
            if open[unit] != ""
                o.puts open[unit]
            end
        end
    end
end
o.close
system("ruby xml_to_conllu_sm.rb #{ARGV[0]}#{filecounter}.xml #{ARGV[1]}")
File.delete("#{ARGV[0]}#{filecounter}.xml")

#for i in 1..filecounter ###
#    STDERR.puts i
#    system("ruby xml_to_conllu_sm.rb #{ARGV[0]}#{i}.xml #{ARGV[1]}")
#    File.delete("#{ARGV[0]}#{i}.xml")
#end

STDERR.puts "Creating large conllu..."
outfile = File.open("#{ARGV[0]}_#{ARGV[1]}.conllu","w:utf-8")

for i in 1..filecounter ###
    STDERR.puts i 
    infile = File.open("#{ARGV[0]}#{i}.conllu","r:utf-8")
    infile.each_line do |line|
        outfile.puts line
    end
    infile.close
    File.delete("#{ARGV[0]}#{i}.conllu")
end
outfile.close