{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}
module Models.RunningWeekItems where 

import InitDB
import LineItemDB
import Config
import BudgetMgr
import WebApp

import Yesod

data RunningWeekItems = RunningWeekItems {
    items :: [LineItem],
    isStartOfWeek :: Bool
  }

instance ToJSON RunningWeekItems where
  toJSON RunningWeekItems {..} = object
    [   "items" .= items
      , "isStartOfWeek" .= isStartOfWeek
    ]

-- why this doesn't work with the record wildcard ?
instance ToJSON LineItem where
  toJSON (LineItem name amount) = object
    [   "name" .= name
      , "amount" .= amount
    ]

readRunningWeekItems :: (HasWebApp m, MonadIO m) => m RunningWeekItems
readRunningWeekItems = runDB' $ do
  items <- getAllItems
  isStartOfWeek <- liftIO $ do
    d <- readStartDayOfWeek
    newWeekCheck d
  return $ RunningWeekItems {..}