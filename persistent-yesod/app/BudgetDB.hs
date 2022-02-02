{-# LANGUAGE TypeApplications           #-}

module BudgetDB where 
  
import Control.Monad.Reader
import Data.Maybe (fromMaybe)

import Database.Persist.Postgresql as S 
import Database.Esqueleto.Experimental

import InitDB 
import BudgetMgr

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
setWeeklyBudget :: (MonadIO m) => Double -> SqlPersistT m ()
setWeeklyBudget amt =  do
  budgetExists <- S.exists [BudgetAmount S.!=. 0]
 
  if budgetExists
    -- now that we're in a long-term persistent storage, it's time to stop
    --    updating the budget each time we run the program
    then pure ()
    else insert_ $ Budget amt True
    

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