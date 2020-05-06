codes <- read.csv(input_files[[1]], header=FALSE)$V1
finals <- read.csv(input_files[[2]])$Username

setdiff(finals, codes)
setdiff(codes, finals)


