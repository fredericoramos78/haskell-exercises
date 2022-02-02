{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}

module Models.WeeklySummary where

import InitDB
import BudgetDB
import BudgetMgr
import Config
import LineItemDB
import WebApp

import Models.RunningWeekItems

import Yesod
import Control.Monad
import Database.Esqueleto.Experimental


data WeeklySummary = WeeklySummary {
    spent :: Double,
    budget :: Double,
    items :: [LineItem],
    isStartOfWeek :: Bool
  }

instance ToJSON WeeklySummary where
  toJSON WeeklySummary {..} = object
    [   "spent" .= spent
      , "budget"  .= budget
      , "remaining" .= (budget - spent)
      , "items" .= items
      , "isStartOfWeek" .= isStartOfWeek
    ]

readWeeklySummary :: (HasWebApp m, MonadIO m) => m WeeklySummary
readWeeklySummary = runDB' $ do
  spent <- getLineItemsTotal
  budget <- getWeeklyBudget
  items <- getAllItems
  -- can rewrite to liftIO $ readStartDayOfWeek >>= newWeekCheck
  -- not sure if that's preferred or not
  isStartOfWeek <- liftIO $ do
    d <- readStartDayOfWeek
    newWeekCheck d
  return $ WeeklySummary {..}
