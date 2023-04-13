def mean(array)
    sum = 0.0
    array.each do |x|
        sum += x
    end
    mean = sum / array.length
    return mean
end

def stdev(array) #calculate standard deviation
    n = array.length.to_f
    squaresum = 0.0
    mean = mean(array)
    array.each do |x|
        squaresum += (x - mean) ** 2
    end
    stdev = Math.sqrt(squaresum/(n-1))
    return stdev
end


def zscore(array)
    zscores = []
    mean = mean(array)
    stdev = stdev(array)
    array.each do |x|
        zscores << (x - mean) / stdev
    end
    return zscores
end

def cosine_delta(array1,array2)
    z1 = zscore(array1)
    z2 = zscore(array2)
    dist = 1 - (dot_product(z1,z2) / (euclidean_norm(z1) * euclidean_norm(z2)))
    return dist
end


def dot_product(array1,array2)
    dp = 0.0
    array1.each_index do |index|
        dp += array1[index] * array2[index]
    end
    return dp
end

def euclidean_norm(array)
    norm = Math.sqrt(dot_product(array,array))
    return norm
end

def div_by_zero(a,b)
    if b != 0
        c = a.to_f/b
    else
        c = 0.0
    end 
    return c
end 

