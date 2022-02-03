module WebApp where
  
import Database.Persist.Postgresql as S
import Data.Pool
import Control.Monad.Reader

newtype WebApp = WebApp ConnectionPool

class HasWebApp m where 
  getWebApp :: m WebApp 
  

runDB' :: (HasWebApp m, MonadIO m) => SqlPersistT IO a -> m a 
runDB' body = do
  (WebApp pool) <- getWebApp  
  liftIO $ runSqlPool body pool