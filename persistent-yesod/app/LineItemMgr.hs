module LineItemMgr where 

import InitDB

readItem :: IO (Maybe LineItem) 
readItem = do
  putStrLn "What's the item name? (type '.' to stop)"
  name <- getLine 
  case name of 
    "." -> return Nothing
    _   -> do 
            putStrLn "How much it cost?"
            iPrice <- read <$> getLine
            return $ Just $ LineItem name iPrice  
  
readItems :: [LineItem] -> IO [LineItem]
readItems allItems = readItem >>= continueOrEnd allItems   

continueOrEnd :: [LineItem] -> Maybe LineItem -> IO [LineItem]
continueOrEnd allItems Nothing = do
  putStrLn "End of inputting items"
  return allItems 
continueOrEnd allItems (Just item) = readItems (item : allItems)