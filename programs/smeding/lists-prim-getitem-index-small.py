# getting an item from an index with an index that is too small

expectException(IndexError)
["a","b","c"].__getitem__(-5)
