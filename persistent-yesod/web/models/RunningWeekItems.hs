{-# LANGUAGE OverloadedStrings #-}
module Models.RunningWeekItems where 

import InitDB
import LineItemDB
import WebApp

import Yesod


instance ToJSON LineItem where
  toJSON (LineItem name amount) = object
    [   "name" .= name
      , "amount" .= amount
    ]

readRunningWeekItems :: (HasWebApp m, MonadIO m) => m [LineItem]
readRunningWeekItems = runDB' getAllItems