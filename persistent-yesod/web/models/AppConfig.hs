{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}

module Models.AppConfig where 
  
import Config
import BudgetDB
import WebApp
  
import Data.Time
import Yesod
  
data AppConfig = AppConfig 
  { weekStartDay :: DayOfWeek, 
    weeklyBudget :: Double 
  } deriving Show

instance ToJSON AppConfig where 
  toJSON AppConfig {..} = object
          [ "week-starts-at" .= weekStartDay
          , "weekly-budget"  .= weeklyBudget
          ]

loadAppConfig :: WebApp -> IO AppConfig 
loadAppConfig (WebApp pool) = do 
  budget <- runDB' pool getWeeklyBudget 
  startOfWeek <- readStartDayOfWeek
  return $ AppConfig Monday budget