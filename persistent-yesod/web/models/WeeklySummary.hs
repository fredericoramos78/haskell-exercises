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
import Yesod.Core.Content
import Control.Monad
import Data.Aeson
import Database.Esqueleto.Experimental


data WeeklySummary = WeeklySummary 
  { spent :: Double
  , budget :: Double
  , items :: [LineItem]
  , isStartOfWeek :: Bool
  }

instance ToJSON WeeklySummary where
  toJSON WeeklySummary {..} = object
    [ "spent" .= spent
    , "budget"  .= budget
    , "remaining" .= (budget - spent)
    , "items" .= items
    , "isStartOfWeek" .= isStartOfWeek
    ]

instance ToTypedContent WeeklySummary where 
  toTypedContent = TypedContent typeJson . toContent

instance ToContent WeeklySummary where 
  toContent = toContent . encode

readWeeklySummary :: (HasWebApp m, MonadIO m) => m WeeklySummary
readWeeklySummary = runDB' $ do
  spent <- getLineItemsTotal
  budget <- getWeeklyBudget
  items <- getAllItems
  isStartOfWeek <- isStartOfTheWeek
  return $ WeeklySummary {..}
