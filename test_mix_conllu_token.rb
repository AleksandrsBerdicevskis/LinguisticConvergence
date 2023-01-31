
istart = ARGV[0] #100
ifinish = ARGV[1] #109
ntokens = ARGV[2].to_i #300
ntexts = ARGV[3].to_i #6
dir = ARGV[4] #Sets1000

o1 = File.open("#{dir}\\Set#{istart}_#{ifinish}FacitSimple.tsv","w:utf-8")
o2 = File.open("#{dir}\\Set#{istart}_#{ifinish}Facit.tsv","w:utf-8")
o2.puts "Set\ta\tb\tc\td\te"
#l = File.open("#{dir}\\Set#{istart}_#{ifinish}SentenceLength.tsv","w:utf-8")
#l.puts "Set\tA\tB"

#ntokens = 0

def distribute_across_sets(sentencearray, ntokens, ntexts, denom, label)
    sets = Hash.new{|hash,key| hash[key] = Array.new} 
    samplesource = (1..ntokens).to_a #numbers (keys) that we will use for sampling
    for j in 0..ntexts-1
        samplesize = (j.to_f/denom)*ntokens #how many %, e.g.: 0, 20, 40, 60 etc.
        #STDERR.puts samplesize
        currentsample = samplesource.sample(samplesize)
        samplesource = samplesource.reject{|k| currentsample.include?(k)} # remove all the used numbers from the source
        currentsample.each do |sentindex| # add all the chosen numbers to the sample
            #asets[j] << "#{a[sentindex-1].strip} \tTextA"
            #sentencearray[sentindex-1] << label
            sets[j] << sentencearray[sentindex-1]
        end
    end
    return sets
end


def read_conllu_to_array(f)
    array = Array.new{Array.new}
    #sentence = []
    f.each_line do |line|
        line1 = line.strip
        if line1 != ""
            if line1[0] != "#"
                array << line1
            end
        else
            #array << sentence
            #sentence = []
        end
    end
    return array
end

def sumnum(n)
    sum = 0.0
    for i in 1..n-1
        sum += i
    end
    return sum
end
    
def print_conllu(o, array)
    array.each do |line|
        o.puts line
        #o.puts 
    end
end

for i in istart..ifinish
    #STDERR.puts ntokens
    if !Dir.exists?("#{dir}\\Set#{i}")
        Dir.mkdir("#{dir}\\Set#{i}")
    end
    
    f1 = File.open("#{dir}\\Set#{i}TextA.conllu","r:utf-8")
    f2 = File.open("#{dir}\\Set#{i}TextB.conllu","r:utf-8")
    
    #reading scrambling sentences 
    a = read_conllu_to_array(f1).shuffle
    b = read_conllu_to_array(f2).shuffle
    #STDERR.puts a.length
    #STDERR.puts b.length
    #read in as tokens
    #print as tokens
    #remove sentence lengths? 

    denom = sumnum(ntexts) #how many parts does the text have to be split into
    #STDERR.puts denom
    #a = a.sample(ntokens) #we will not use all sentences
    #b = b.sample(ntokens)
    #STDERR.puts a.length
    #STDERR.puts b.length
        


    #STDERR.puts "Comparing sentence lengths..." #for information
    #n1 = 0.0
    #a.each do |sentence|
    #    n1 += sentence.length
    #end
    #STDERR.puts 
    
    #n2 = 0.0
    #b.each do |sentence|
    #    n2 += sentence.length
    #end
    #l.puts "#{i}\t#{n1/a.length}\t#{n2/b.length}"
    
    #STDERR.puts "a"
    asets = distribute_across_sets(a, ntokens, ntexts, denom, "TextA")
    #STDERR.puts "b"
    bsets = distribute_across_sets(b, ntokens, ntexts, denom, "TextB")
    
    #combining sentence from A and B into every set
    sets = Hash.new{|hash,key| hash[key] = Array.new}
    for j in 0..ntexts-1
        sets[j] = (asets[j] + bsets[ntexts-j-1]).shuffle
    end
    
    letterhash = {1 => "a", 2 => "b", 3 => "c", 4 => "d", 5 => "e", 6 => "f", 7 => "g", 8 => "h", 9 => "i", 10 => "j"}
    
    scrambled = (1..ntexts-1).to_a.shuffle
    correct = []
    #scrambled_letters = []
    scrambled.each.with_index do |real,index|
        correct[real] = letterhash[index+1]
        scrambled[index] = scrambled[index].to_f/(ntexts-1)
        #scrambled_letters << letterhash[index+1]
    end
   
    o1.puts "Set#{i}\tbase\t#{correct[1..-1].join("\t")}"
    o2.puts "Set#{i}\t#{scrambled.join("\t")}"
    o = File.open("#{dir}\\Set#{i}\\base.conllu","w:utf-8")
    print_conllu(o, sets[0])
    o.close
    
    correct[1..-1].each.with_index do |letter, index|
        o = File.open("#{dir}\\Set#{i}\\text#{letter}.conllu","w:utf-8")
        print_conllu(o, sets[index+1])
        o.close
    end

end