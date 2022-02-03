{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE RecordWildCards  #-}
module BudgetDB where 
  
import Control.Monad.Reader
import Data.Maybe (fromMaybe, isJust)

import Database.Persist.Postgresql as S (exists, (==.)) 
import Database.Esqueleto.Experimental

import InitDB 
import LineItemDB
import BudgetCommons
import CalUtils
--import BudgetMgr

getWeeklyBudget :: (MonadIO m) => SqlPersistT m Double  
getWeeklyBudget = do
  -- budget is a `Maybe (Value Int)` where `Value Int` is the projection of the `amount` column. It's a `Maybe` b/c
  --    of the `selectOne` behaviour
  budget <- selectOne $ do 
    b <- from $ table @Budget
    pure $ b ^. BudgetAmount 
  -- Now that we have the value out of the db, we can tweak it to have a `.map().getOrElse()`-like which will move the 
  --    `Maybe` out of the equation and result in an `Int`  
  pure $ fromMaybe defaultWeeklyBudget $ fmap unValue budget 
  
-- updates the weekly budget (or inserts it if there's no row -- aka upsert)    
setWeeklyBudget :: (MonadIO m) => Double -> Bool -> SqlPersistT m ()
setWeeklyBudget amt overrideIfExists =  do
  budget <- selectOne $ from $ table @Budget
  case (budget, overrideIfExists) of
    (Nothing, _) -> insert_ $ Budget amt True
    (Just budget, True) -> update $ \b -> do
      -- will keep which ever start day is configured
      set b [ BudgetAmount =. val amt ]
    _ -> pure()
    
-- version of `setWeeklyBudget` that only inserts (=doesn't update)
addWeeklyBudget :: (MonadIO m) => Double -> SqlPersistT m ()
addWeeklyBudget = flip setWeeklyBudget False 

setWeeklySpent :: (MonadIO m) => Int -> Double -> SqlPersistT m Bool
setWeeklySpent week amount = do 
    spendExists <- S.exists [WeeklySpendHistoryWeek S.==. week]
    
    if spendExists
      then pure False 
      -- using `>>` as opposed to a `do` notation just to exercise it ;)
      else insert_ (WeeklySpendHistory week amount) >> return True

getWeeklySpendHistory :: (MonadIO m) => SqlPersistT m [WeeklySpendHistory]
getWeeklySpendHistory = do
  spentHistory <- select $ do
    from $ table @WeeklySpendHistory
  return $ entityVal <$> spentHistory

resetWeek :: (MonadIO m) => Bool -> SqlPersistT m (Bool, Int)
resetWeek False = return (False, 0)
resetWeek _ = do
  weekId <- liftIO calculateThisWeek
  existingTotal <- getLineItemsTotal
  deleteCount <- cleanupLineItems
  weekSumCreated <- setWeeklySpent weekId existingTotal
  pure (weekSumCreated, deleteCount)