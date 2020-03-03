#Import Library
library(RSelenium)

#ID & Password Mudley World
myemail<-"email address"
pwd<-"password"

#Web Scraping with RSelenium package
driver<-rsDriver(browser = c("chrome"))
remDr<- driver[["client"]]

#Mudley World Log in page
remDr$navigate("https://www.mudleyworld.com/user/login")

#Mail ID for Mudley World 

mailid<-remDr$findElement(using = 'xpath',  "//*[(@id = 'login-form-login')]")


mailid$sendKeysToElement(list(myemail))

#Password for Mudley World

password<-remDr$findElement(using = 'xpath', "//*[(@id = 'login-form-password')]")

password$sendKeysToElement(list(pwd))

#Submit id/password to Mudley World

login <- remDr$findElement(using = 'xpath',"//*[contains(concat( ' ', @class, ' ' ), concat( ' ', 'tee-button', ' ' ))]")

login$clickElement()
 
#Import Library
library(rvest)
library(xml2)
library(tidyverse)
library(abind)
library(lubridate)
library(gridExtra)

#Scrap Data from the first page

url<-"https://www.mudleyworld.com/guild/statement?page=1"

remDr$navigate(url)

pg<-read_html(remDr$getPageSource()[[1]])%>%html_nodes(xpath = '//*[@id="w1"]/table')%>%html_table()%>%as.data.frame()

#Clean Na row
clean_statement<-drop_na(pg)

#Spread create time column to 2 columns date & time
clean_statement2<-separate(clean_statement,col=Created.Time,into=c("Date","Time"),sep=" ")

clean_statement3<-clean_statement2[, -1]

#Change class of columns
clean_statement3$Balance<-as.numeric(clean_statement3$Balance)
clean_statement3$Date<-ymd(clean_statement3$Date)
clean_statement3$Time<-hms(clean_statement3$Time)

#Line plot for balance vs date
ggplot(clean_statement3,aes(x=Date,y=Balance))+geom_smooth()+labs(x="Date", y="Guild Exp.",title="Road To Trader Team B")

#Save data frame to image by using gridExtra Packages

png(filename = "Guildstatement_page1.png", width=800,height=500,bg = "white")
grid.table(clean_statement3)
dev.off()

#After finish work, stop server

remDr$close()
driver$server$stop()
driver$server$process

