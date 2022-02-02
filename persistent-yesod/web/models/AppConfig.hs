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

loadAppConfig :: (HasWebApp m, MonadIO m) => m AppConfig 
loadAppConfig = do 
  weeklyBudget <- runDB' getWeeklyBudget 
  weekStartDay <- liftIO readStartDayOfWeek
  return $ AppConfig {..}