{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}

module Models.WeeklySummary where

import InitDB
import BudgetDB
import LineItemDB
import WebApp

import Yesod
import Control.Monad
import Database.Esqueleto.Experimental


data WeeklySummary = WeeklySummary {
    spent :: Double,
    budget :: Double,
    items :: [LineItem]
  }

instance ToJSON WeeklySummary where
  toJSON WeeklySummary {..} = object
    [   "spent" .= spent
      , "budget"  .= budget
      , "remaining" .= (budget - spent)
      , "items" .= items
    ]

instance ToJSON LineItem where
  toJSON (LineItem name amount) = object
    [   "name" .= name
      , "amount" .= amount
    ]

readWeeklySummary :: WebApp -> IO WeeklySummary
readWeeklySummary (WebApp pool) = do
  (totalSpent, budget, allItems) <- runDB' pool $ do
    s <- getLineItemsTotal
    b <- getWeeklyBudget
    i <- getAllItems
    return (s, b, i)
  return $ WeeklySummary totalSpent budget allItems
