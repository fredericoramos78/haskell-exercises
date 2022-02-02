{-# LANGUAGE OverloadedStrings #-}
module Models.WeeklySpendHistory where 

import InitDB
import BudgetDB
import WebApp

import Yesod


instance ToJSON WeeklySpendHistory where
  toJSON (WeeklySpendHistory week amount) = object
    [   "weekOfYear" .= week
      , "amount" .= amount
    ]

readSpendHistory :: (HasWebApp m, MonadIO m) => m [WeeklySpendHistory]
readSpendHistory = runDB' getWeeklySpendHistory