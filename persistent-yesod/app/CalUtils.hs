module CalUtils where 
  
import Control.Monad.Reader
import Hledger.Data.Dates
import Data.Time
import Data.Time.Calendar.OrdinalDate

calculateThisWeek :: IO Int 
calculateThisWeek = fst . mondayStartWeek <$> getCurrentDay 

isWeekBreakDay :: (MonadIO m) => DayOfWeek -> m Bool 
isWeekBreakDay d = do 
  today <- liftIO getCurrentDay
  let dow = dayOfWeek today 
  pure $ dow == d