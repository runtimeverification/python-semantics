# getting an item from an index with an index that is too large

expectException(IndexError)
["a","b","c"].__getitem__(3)
