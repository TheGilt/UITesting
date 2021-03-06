if (!exists("context_of")) source("initialize.R")

pageURL <- paste0(siteURL, "/project/home/begin.view")
context_of(file = "test-home.R", 
           what = "Home", 
           url = pageURL)

test_that("can connect to the page", {
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
    
    while(remDr$getTitle()[[1]] == "Sign In") Sys.sleep(1)
  }
  pageTitle <- remDr$getTitle()[[1]]
  expect_equal(pageTitle, "News and Updates: /home")
})

test_that("'Quick Help' is present", {
  remDr$executeScript("LABKEY.help.Tour.show('immport-home-tour')")
  
  quickHelp <- remDr$findElements(using = "css selector", 
                                  value = "div[class='hopscotch-bubble animated']")
  expect_equal(length(quickHelp), 1)
  
  if (length(quickHelp) == 1) {
    titles <- c("Welcome to ImmuneSpace", 
                "Announcements", 
                "Quick Links", 
                "Tools", 
                "Tutorials", 
                "About", 
                "Video Tutorials Menu", 
                "Studies Navigation")
    for (i in seq_along(titles)) {
      helpTitle <- quickHelp[[1]]$findChildElements(using = "class", 
                                                    value = "hopscotch-title")
      expect_equal(helpTitle[[1]]$getElementText()[[1]], titles[i])
      
      nextButton <- quickHelp[[1]]$findChildElements(using = "class", 
                                                     value = "hopscotch-next")
      expect_equal(length(nextButton), 1)

      closeButton <- quickHelp[[1]]$findChildElements(using = "class", 
                                                      value = "hopscotch-close")
      expect_equal(length(closeButton), 1)
      
      if (i == length(titles)) {
        closeButton[[1]]$clickElement()
      } else {
        nextButton[[1]]$clickElement()
      }
    }
  }
})

test_that("'Public Data Summary' module is present", {
  summaryTab <- remDr$findElements(using = "css selector", value = "[id^=Summary]")
  expect_equal(length(summaryTab), 1, info = "Does 'Public Data Summary' module exist?")
  
  rows <- summaryTab[[1]]$findElements(using = "css selector", value = "tr")
  expect_gt(length(rows), 0)
})

test_that("`Studies` tab shows studies properly", {
  studyTab <- remDr$findElements(using = "id", value = "StudiesMenu12-Header")
  studyTab[[1]]$clickElement()
  Sys.sleep(1)
  
  studyList <- remDr$findElements(using = "css selector", value = "div[id=studies]")
  expect_equal(length(studyList), 1, info = "Does 'Studies' tab exist?")
  
  studyElems <- strsplit(studyList[[1]]$getElementText()[[1]], "\n")[[1]]
  studies <- studyElems[grepl("SDY\\d+", studyElems)]
  studyNumber <- as.integer(sub("\\*", "", sub("SDY", "", studies)))
  expect_equal(studyNumber, sort(studyNumber), info = "Are studies in order?")
  
  HIPC <- grepl("\\*", studies)
  expect_gt(sum(HIPC), 0)
})
