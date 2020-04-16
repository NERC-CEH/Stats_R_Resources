# stringr

# basic manipulations

# string concatenation
storms <- dplyr::storms
#default separator is ""
str_c(storms$status,storms$name)
#default separator is whitespace
paste(storms$status,storms$name)

# text length
some_text = c("one", "two", "three", NA, "five")
nchar(some_text)
str_length(some_text)


# extract substrings
UKCEH = "uk centre for ecology and hydrology"
substring(UKCEH, first = 4, last = 35)
str_sub(UKCEH, start = 4, end = 35)
#str_sub lets you work with negative indices too
str_sub(UKCEH, start = -32, end = -15)
substring(UKCEH, first = -32, last = -15)


# padding strings
numbers <- tibble(x = c(252,2400,82000), y = c(12,6,312))
numbers
str_pad(numbers$x, width = 5, side = "left", pad = "0")





# regular expressions
# detect matches
fruit <- tibble(x = c("apple", "pear", "watermelon", "banana", "cherry", "blueberry"))
str_detect(fruit$x, "a")
grepl("a", fruit$x)

# replace patterns
str_replace_all(fruit$x, "a", "oo")
gsub("a", "oo", fruit$x)
          