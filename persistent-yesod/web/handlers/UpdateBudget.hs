{-# LANGUAGE OverloadedStrings #-}
module Handlers.UpdateBudget where 

import Yesod
import Yesod.Core.Types
import Data.Aeson.Types
import Data.Text (pack)

import Models.WeeklySummary
import Models.WeeklySpendHistory
import Routes
import WebApp

import InitDB
import BudgetDB

data PutBudgetAmountRequest = PutBudgetAmountRequest 
    { amount :: Double
    } 
    -- deriving strategies
    -- deriving stock Generic
    -- deriving anyclass FromJSON

instance FromJSON PutBudgetAmountRequest where 
    parseJSON (Object v) = PutBudgetAmountRequest <$> (v .: "amount")

putBudgetAmountR :: Handler WeeklySummary
putBudgetAmountR = do 
    -- returns a `Result a` which can be either a `Success` or `Error`
    -- https://hackage.haskell.org/package/yesod-core-1.6.21.0/docs/Yesod-Core-Json.html#v:parseCheckJsonBody
    parseResult <- parseCheckJsonBody
    case parseResult of
        Success (PutBudgetAmountRequest amt) -> do
            runDB' $ setWeeklyBudget amt True
            readWeeklySummary
        Error msg -> 
            invalidArgs [pack msg]

postResetWeekR :: Handler [WeeklySpendHistory]
postResetWeekR = do 
    runDB' $ resetWeek True 
    readSpendHistory 

     