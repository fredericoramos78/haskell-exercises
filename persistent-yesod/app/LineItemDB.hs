{-# LANGUAGE TypeApplications           #-}

module LineItemDB where

import Control.Monad.Reader
import Data.Maybe (fromMaybe)

import Database.Esqueleto.Experimental

import InitDB

insertNewItem :: (MonadIO m) => LineItem -> SqlPersistT m ()
insertNewItem i = insertNewItems [i]

insertNewItems :: (MonadIO m)  => [LineItem] -> SqlPersistT m ()
insertNewItems = insertMany_

getAllItems :: (MonadIO m) => SqlPersistT m [LineItem]
getAllItems = do
  allItems <- select $ do
    from $ table @LineItem
  return $ entityVal <$> allItems


getLineItemsTotal :: (Num a, MonadIO m, PersistField a) => SqlPersistT m a
getLineItemsTotal = selectSum $ do
    items <- from $ table @LineItem
    return $ sum_ $ items ^. LineItemAmount
  where
    -- selectOne is a `SqlPersistT m (Maybe a)` where `a` is a `Value (Maybe Int)`
    --    the outer `Maybe` represents the possibility of no rows
    --    the inner `Maybe` the possibility of no values to sum
    -- (maybe 0 f) runs `f` on a `Maybe` and returns either the result of `f` (if it's a `Just`) or `0` if `Nothing`
    --      `f` should be `a -> b`, but since that's a `Value (Maybe x)` we need to
    --             -- a. `unvalue` to wrap out the `Value`
    --             --
    selectSum = fmap (maybe 0 (fromMaybe 0 . unValue)) . selectOne

cleanupLineItems :: (MonadIO m) => SqlPersistT m Int
cleanupLineItems = do
   dCount <- deleteCount $ do
      _ <- from $ table @LineItem
      pure ()
   pure $ fromIntegral dCount
