# REDIS Command Cheatsheet

## Data types

- **String**
- **Hashes**
- **List**
- **Sets**
- **Sorted sets**
- **Bitmaps**
- **HyperLogLog**
- **Geo spatial indexes**

### String

- `set key value`
- `get key`
- `getrange key start end`
- `getrange email 0 4` - First five characters of the value

#### set/get multiple values

- `mset key0 value0 key1 value1 ... keyN valueN`
- `mget key0 keyN`
- `strlen key` - length of the string value, 0 if the key is not present
- `del keys` - Delete the specified keys.
- `incr/decr key` - To increment/decrement integer value
- `incrby/decrby key steps` - To increment/decrement by `steps` times
- `incrbyfloat/decrbyfloat` - To increment/decrement float values
- `expire key time` - Expire key after a timeout. After expiration, the value would be (nil)
- `ttl key` - To know remaining time to expire,
  - **-1** indicates that the value has not been started expiring
  - **-2** indicates that the value has been expired

- `persist key` - Removes the expiration from a key.
- `set key duration value` Set value with expiration
- `keys regex` - gives keys as per the regex pattern. i.e. * for all the keys
- `flushall` - remove all the key-value pairs.

### Lists

- `lpush/rpush key values` - Make a list of values. Recent value would be on left/right.
- `lrange key start end` - Print list in range, Support negative index(-1 for the last element)
- `llen key` - Gives list size. 0 if not exists.
- `lpop/rpop` - Returns and removes leftmost/rightmost element of the list.
- `lset key index newValue` - Updates the value at the given index.
- `linsert key before|after pivot value` - Insert value before/after given pivot. Return -1 if the pivot is not found.
- `lindex key index` - Return the value at given index. (nil) if not in range.
- `lpushx/rpushx key value` - Push value only if the key exists. Gives Length Otherwise 0.
- `sort key pattern` - Print sorted list as per the pattern(ALPHA).
  - **ALPHA** - Alphabetically
  - **ASC|DESC** - Ascending|Descending order
  - **STORE destination** - Store the result into destination instead of printing.
  - **LIMIT start stop** - Gives the output within the range. (empty array) if the range is out of bound.

### Sets

- `SADD key member [member ...]` - Add one or more members to a set
- `SREM key member [member ...]` - Remove one or more members from a set
- `SMEMBERS key` - Get all the members in a set
- `SISMEMBER key member` - Determine if a given member exists in a set
- `SCARD key` - Get the number of members in a set
- `SINTER key [key ...]` - Intersect multiple sets
- `SUNION key [key ...]` - Add multiple sets
- `SUNIONSTORE destination key [key ...]` - Store union into destination(same for inter, diff)
- `SDIFF key [key ...]` - Minus multiple sets

### Hashes

- `HSET key field value [field value ...]` - Set the string value of a hash field
- `HGET key field` - Get the value of a hash field
- `HMGET key field [field ...]` - Get the values of all the given hash fields
- `HGETALL key` - Get all the fields and values in a hash
- `HDEL key field [field ...]` - Delete one or more hash fields
- `HLEN key` - Get the number of fields in a hash
- `HINCRBY key field increment` - Increment the integer value of a hash field by the given number

### Sorted Sets

- `ZADD key score member [score member ...]` - Add one or more members to a sorted set, or update its score if it already exists
- `ZREM key member [member ...]` - Remove one or more members from a sorted set
- `ZRANGE key start stop [WITHSCORES]` - Return a range of members in a sorted set, by index
- `ZREVRANGE key start stop [WITHSCORES]` - Return a range of members in a sorted set, by index, with scores ordered from high to low
- `ZCARD key` - Get the number of members in a sorted set
- `ZSCORE key member` - Get the score associated with the given member in a sorted set
- `ZCOUNT key min max` - Count members from min to max. (`-inf` for lowest, `+inf` for highest score, inclusive)
- `ZREVRANGEBYSCORE key max min` - Display members in reverse by score
- `ZINCRBY key increment number` - Increment score of a member by the `increment` value.
- `ZREMRANGE key min max` - Remove members of a given range.
