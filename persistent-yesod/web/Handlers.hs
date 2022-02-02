module Handlers where 

import Yesod
import Yesod.Core.Types

import Models.AppConfig
import Models.WeeklySummary
import Routes
import WebApp


getHomeR :: Handler Html
getHomeR = redirect ConfigListR

getConfigListR :: Handler (JSONResponse AppConfig)
-- Type rationale:
-- `loadAppConfig` is `m (AppConfig)`
-- `JSONResponse` is `a -> JSONResponse a`
-- f-mapping will lift `JSONResponse a` over m, giving m (JSONResponse AppConfig)
--    and since this function is in the `Handler x` context, `m` will be
--    concretized into `Handler` to finally get `Handler (JSONResponse AppConfig)`
getConfigListR = JSONResponse <$> loadAppConfig

getWeeklySummaryR :: Handler (JSONResponse WeeklySummary)
getWeeklySummaryR = JSONResponse <$> readWeeklySummary