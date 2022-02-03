module Handlers.GetHandlers where 

import Yesod
import Yesod.Core.Types

import Models.AppConfig
import Models.WeeklySummary
import Models.RunningWeekItems
import Models.WeeklySpendHistory
import Routes
import WebApp

import InitDB
import LineItemDB

getHomeR :: Handler Html
getHomeR = redirect ConfigListR

-- Type rationale (from the time these were `Handler (JSONResponse a)`):
-- `loadAppConfig` is `m (AppConfig)`
-- `JSONResponse` is `a -> JSONResponse a`
-- f-mapping will lift `JSONResponse a` over m, giving m (JSONResponse AppConfig)
--    and since this function is in the `Handler x` context, `m` will be
--    concretized into `Handler` to finally get `Handler (JSONResponse AppConfig)`
--
-- Now that they are using the polymorphic instances on `Orphans`, we don't need to 
--   declare them as `JSONResponse a`. It's still a good practice if there are 
--   endpoints that do not return JSON content (iow, if we have a mix of JSON and non-JSON endpoints)
getConfigListR :: Handler AppConfig
getConfigListR = loadAppConfig

getWeeklySummaryR :: Handler WeeklySummary
getWeeklySummaryR = readWeeklySummary

getItemsForRunningWeekR :: Handler RunningWeekItems
getItemsForRunningWeekR = readRunningWeekItems  

getWeeklySpendHistoryR :: Handler [WeeklySpendHistory]
getWeeklySpendHistoryR = readSpendHistory

     