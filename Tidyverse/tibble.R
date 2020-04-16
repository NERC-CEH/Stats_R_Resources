library(tidyverse)

# tibbles

# printing
# storms data: position and attributes of tropical storms
as.data.frame(dplyr::storms)
head(as.data.frame(dplyr::storms))
str(as.data.frame(dplyr::storms))

dplyr::storms



# altering print options
# rows
options(tibble.print_max = 10, tibble.print_min = 5) #specify rows
options(tibble.print_max = 20, tibble.print_min = 10) #default rows
# columns
options(tibble.width = Inf) #show all cols
options(tibble.width = NULL) #default cols




# non-syntactic column names
# does not adjust names of variables when reading in / creating df
names(data.frame(`col name` = 1))
names(tibble(`col name` = 1))

names(data.frame(`£2` = 1))
names(tibble(`£2` = 1))




# no partial matching
df <- as.data.frame(dplyr::storms)
tb <- dplyr::storms
names(df)
df$y
tb$y




# subsetting: always returns a tibble
df1 <- data.frame(x = 1:3, y = 3:1)
df1
df1_1 <- df1[,1] #vector
df1_1
df1_2 <- df1[,1, drop = FALSE] #df
df1_2

tb1 <- tibble(x = 1:3, y = 3:1)
tb1
tb1_1 <- tb1[,1]
tb1_1





