context("home page")

if (!exists("ISR_login")) source("initialize.R")

test_that("can connect to home", {
  pageURL <- paste0(siteURL, "/project/home/begin.view")
  remDr$navigate(pageURL)
  
  signinURL <- paste0(siteURL, "/login/home/login.view?returnUrl=%2Fproject%2Fhome%2Fbegin.view%3F")
  headermenu <- remDr$findElements(using = "class", value = "headermenu")
  if (headermenu[[1]]$getElementText()[[1]] == "Sign In") {
    remDr$navigate(signinURL)
    
    id <- remDr$findElement(using = "id", value = "email")
    id$sendKeysToElement(list(ISR_login))
    
    pw <- remDr$findElement(using = "id", value = "password")
    pw$sendKeysToElement(list(ISR_pwd))
    
    loginButton <- remDr$findElement(using = "class", value = "labkey-button")
    loginButton$clickElement()
    
    Sys.sleep(1)
  }
  pageTitle <- remDr$getTitle()[[1]]
  expect_equal(pageTitle, "News and Updates: /home")
})

test_that("'Public Data Summary' module is present", {
  summaryTab <- remDr$findElements(using = "css selector", value = "[id^=Summary]")
  expect_equal(length(summaryTab), 1)
  
  rows <- summaryTab[[1]]$findElements(using = "css selector", value = "tr")
  expect_true(length(rows) > 0)
})

test_that("`Studies` tab shows studies properly", {
  studyTab <- remDr$findElements(using = "id", value = "WikiMenu12-Header")
  studyTab[[1]]$clickElement()
  Sys.sleep(0.5)
  
  studyList <- remDr$findElements(using = "css selector", value = "div[id=studies]")
  expect_equal(length(studyList), 1)
  expect_true(sum(grepl("SDY\\d+\\*", strsplit(studyList[[1]]$getElementText()[[1]], "\n")[[1]])) > 0)
})