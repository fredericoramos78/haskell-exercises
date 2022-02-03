{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}
module Models.RunningWeekItems where 

import InitDB
import LineItemDB
import Config
import BudgetMgr
import WebApp

import Yesod

data RunningWeekItems = RunningWeekItems 
  { items :: [LineItem]
  , isStartOfWeek :: Bool
  }

instance ToJSON RunningWeekItems where
  toJSON RunningWeekItems {..} = object
    [ "items" .= items
    , "isStartOfWeek" .= isStartOfWeek
    ]

-- Q: why this doesn't work with the record wildcard ?
-- A: It does if we use the correct field extraction function names. Remember that 
--    Persitent generates those as `[typeName][fieldName]`. 
--    That's why in this case it's not just `name`; it's `lineItemName`.
instance ToJSON LineItem where
  toJSON LineItem {..} = object
    [ "name" .= lineItemName
    , "amount" .= lineItemAmount
    ]

readRunningWeekItems :: (HasWebApp m, MonadIO m) => m RunningWeekItems
readRunningWeekItems = runDB' $ do
  items <- getAllItems
  isStartOfWeek <- liftIO $ do
    d <- readStartDayOfWeek
    newWeekCheck d
  return $ RunningWeekItems {..}