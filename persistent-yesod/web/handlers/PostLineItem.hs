{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RecordWildCards #-}
module Handlers.PostLineItem where 

import Yesod
import Yesod.Core.Types
import Data.Aeson.Types
import Data.Text (pack)

import Models.WeeklySummary
import Routes
import WebApp

import InitDB
import LineItemDB

data PostLineItemRequest = PostLineItemRequest 
    { name :: [Char]
    , amount :: Double
    } 

instance FromJSON PostLineItemRequest where 
    parseJSON (Object v) = PostLineItemRequest 
        <$> v .: "name"
        <*> v .: "amount"

requestToLineItem :: PostLineItemRequest -> LineItem 
requestToLineItem PostLineItemRequest {..} = LineItem name amount

postLineItemR :: Handler (JSONResponse WeeklySummary)
postLineItemR = do 
    parseResult <- parseCheckJsonBody
    case parseResult of
        Success item -> do
            runDB' $ insertNewItem $ requestToLineItem item
            JSONResponse <$> readWeeklySummary
        Error msg -> 
            invalidArgs [pack msg]



     