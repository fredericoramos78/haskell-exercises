module Handlers where 

import Yesod

import Models.AppConfig
import Models.WeeklySummary
import Routes
import WebApp


getHomeR :: Handler Html
getHomeR = redirect ConfigListR

getConfigListR :: Handler Value
getConfigListR = loadAppConfig >>= returnJson

getWeeklySummaryR :: Handler Value  
getWeeklySummaryR = readWeeklySummary >>= returnJson  