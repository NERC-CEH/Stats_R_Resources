# dplyr

# Data: gapminder dataset on population, life exp, GDP/cap by yr and country
# download the data:
gapminder <- read_csv("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv")
gapminder

# Index with select() and subset with filter() ----
 # take the gapminder dataset
 # filter to the rows whose continent is Americas and year is 2007
 # show the country and lifeExp values for these rows
gapminder %>%
  filter(continent == "Americas", year == 2007) %>%
  select(country, lifeExp)

# base R alternative
continent_year_index <- which(gapminder["continent"] == "Americas" & gapminder["year"] == 2007)
gapminder[continent_year_index, c("country", "lifeExp")]



# Create new variables with mutate() ----
gapminder <- gapminder %>% 
  mutate(gdp = gdpPercap * pop)
gapminder

# base alternative
gapminder$gdp = gapminder$gdpPercap*gapminder$pop



# Arrange rows with arrange() ----
# arrange gapminder such that rows are in order of increasing yr
# and countries are in alphabetical order within yr
gapminder %>% 
  arrange(year, country) %>% 
  head
# defaults to ascending order
# for descending order: arrange(desc())


# Apply function to group: group_by()
# filter to country-years that have lifeExp > avg lifeExp for their continent
gapminder %>%
  group_by(continent) %>%
  filter(lifeExp > mean(lifeExp)) %>%
  ungroup() 



# Define summary variable with summarise()
gapminder %>% 
  summarise(mean_lifeExp = mean(lifeExp),
            total_gdp = sum(gdp))

# Useful alongside group_by()
gapminder %>% 
  group_by(year) %>%
  summarise(mean_lifeExp = mean(lifeExp),
            total_gdp = sum(gdp)) 



# Extract distinct values of variable with distinct()
gapminder %>%
  distinct(continent)

# base alternative
unique(gapminder$continent)




# What if you want to apply a dplyr function to several columns at once? ----
# Scoped verbs!  
# _if(): perform an operation on variables that satisfy a logical criteria
# _at(): perform an operation only on variables specified by name
# _all(): perform an operation on all variables at once

# Will illustrate these below for summarise()
tib <- tibble(
  x = runif(100),
  y = runif(100),
  z = runif(100)
)
tib

# summarise_all
summarise_all(tib, mean)
# summarise_all for multiple functions
summarise_all(tib, funs(min, max, mean))

# summarise_at
# for all columns but z
summarise_at(tib, vars(-z), mean)

# summarise_if
# find mean for numeric columns in gapminder
gapminder %>%
  summarise_if(is.numeric, mean)

# Will be replaced by across() in dplyr 1.0.0
# See: https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/