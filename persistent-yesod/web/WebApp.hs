module WebApp where 
  
import Database.Persist.Postgresql as S
import Data.Pool
import Control.Monad.Reader

newtype WebApp = WebApp ConnectionPool


runDB' :: Pool SqlBackend -> ReaderT SqlBackend IO a -> IO a 
runDB' pool body = do
  let result = runSqlPool body pool
  liftIO result