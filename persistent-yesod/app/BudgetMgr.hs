{-# LANGUAGE OverloadedStrings #-}
module BudgetMgr where 
  
import Data.Char (toLower)
import Data.Time

import CalUtils

defaultWeeklyBudget :: Double
defaultWeeklyBudget = 100

newWeekCheck :: DayOfWeek -> IO Bool
newWeekCheck weekBreakDay = do  
  -- check if Monday
  isMondayFlag <- isWeekBreakDay weekBreakDay 
  if isMondayFlag 
    then
      do 
        putStrLn "Today is Monday. Do you want to reset your items (y/N)?"
        r <- getLine
        return $ (==) 'y' . toLower . head $ withDefault "N" r 
    else 
      pure False

withDefault :: String -> String -> String 
withDefault d r = if null r then d else r  
 
