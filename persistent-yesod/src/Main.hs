{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE UndecidableInstances       #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}

module MainExe where

import Data.List (intercalate)
import Control.Monad.Reader
import Control.Monad.Logger
import Data.Pool
import Database.Persist.Postgresql as S

import CMDLineApp
import InitDB

import LineItemDB
import BudgetDB
import LineItemMgr
import BudgetMgr
import CalUtils
import Config 




runApp :: AppT ()
runApp = do
  -- these next 3 lines are wrapped up in the same db transaction
  (totalSpent, budget, allItems) <- runDB $ do
    totalSpent <- getLineItemsTotal
    budget <- getWeeklyBudget
    allItems <- getAllItems
    return (totalSpent, budget, allItems)

  let allItemsLine = intercalate "\n" $ if null allItems then [" nothing!"] else show <$> allItems
      budgetLeft = budget - totalSpent
      budgetLine = concat [
        "Budget is $",
        show budget,
        " and so far I've spent $",
        show totalSpent,
        ". Still have $",
         show budgetLeft,
         " left this week.",
         "\n\n",
         "This week I bought:\n"
       ]
  liftIO $ putStrLn $ budgetLine ++ allItemsLine

main :: IO ()
main = mainWithBudget defaultWeeklyBudget

mainWithBudget :: Double -> IO ()
mainWithBudget budget = do
  --                         Env :: Pool SqlBackend -> Env
  --                         create???Pool :: m (Pool SqlBackend)
  --                         <$> ==> m (Env (Pool SqlBackend))
  env <- runStderrLoggingT $ Env <$> createPostgresqlPool "postgresql://lunch:pass123@localhost:5432/lunchdb" 1
  runAppT initMigration env
  -- check for new weeks
  weekBreakDay <- readStartDayOfWeek
  liftIO $ print $ "Week break day configured as " ++ show weekBreakDay
  resetWeekFlag <- newWeekCheck weekBreakDay
  (resetHappened, resetCount) <- runAppT (resetWeek resetWeekFlag) env
  liftIO $ print $ "Weekly reset happened ? => " ++ show resetHappened ++ ". Delete count was " ++ show resetCount
  -- reading any new items
  newItems <- readItems []
  runAppT (bootstrapDB budget newItems) env
  runAppT runApp env

resetWeek :: Bool -> AppT (Bool, Int)
resetWeek False = return (False, 0)
resetWeek _ = do
  weekId <- liftIO calculateThisWeek
  runDB $ do
    existingTotal <- getLineItemsTotal
    deleteCount <- cleanupLineItems
    weekSumCreated <- setWeeklySpent weekId existingTotal
    pure (weekSumCreated, deleteCount)




