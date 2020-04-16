# pipes

# altered example from https://www.datacamp.com/community/tutorials/pipe-r-tutorial
# NOTE: using functions from tidyverse
# data: baby names in USA since 1880
library(babynames)

# Aim: count how many babies have ever been named "Hannah" 
sum(select(filter(babynames,sex=="F",name=="Hannah"),n))

# Intermediate assignments
bn_filter <- filter(babynames,sex=="F",name=="Hannah")
bn_select <- select(bn_filter,n)
bn_sum <- sum(bn_select)

# Overwriting assignments
bn <- babynames
bn <- filter(bn,sex=="F",name=="Hannah")
bn <- select(bn,n)
bn <- sum(bn)

# Do the same but now with %>%
babynames %>% filter(sex=="F",name=="Hannah") %>%
          select(n) %>%
          sum

