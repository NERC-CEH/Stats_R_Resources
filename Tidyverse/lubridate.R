library(lubridate)
# lubridate

# read in dates
dates <- read_csv("dates.csv")
dates
class(dates$dates_2020)
# convert easily to R date class 
dates$dates_2020 <- dmy(dates$dates_2020)
class(dates$dates_2020)
# functions exist for most inputs, e.g. mdy, ydm
# also hour-minute-second, e.g. dmy_hms()


# simple conversions for many date-time formats
# if your date is no. seconds since 1970-01-01 00:00:00 (zero-time)
as_datetime(1586340398, tz = "Europe/London")
# no. days since 1970-01-01
as_date(18367)


# convert minutes to hours
hms::as_hms(212)


# can find current time / date
now()
today()

# round date-times
# e.g. 2020 dates from above to year
floor_date(dates$dates_2020, unit = "year")


# math with dates
# can find intervals and durations



# Why not use base R?
# A few examples showing how to do an action in base R vs lubridate

date <- as.POSIXct("01-02-2010", format = "%d-%m-%Y", tz = "Europe/London")
date <- dmy("01-02-2010", tz = "Europe/London")

# extract day / month / year from a date
# base
as.numeric(format(date, "%m"))
# lubridate
day(date)
month(date)
year(date)
# can also do this on a whole df
day(dates$dates_2020)

# alter date object
date <- as.POSIXct(format(date,"%Y-5-%d"), tz = "UTC")
month(date) <- 5

