还记得大学刚学数据库那会儿，天真地以为世界上所有的存储都需要用数据库来做。后来毕业后，正值NOSQL流行，那时我在网易参与了网易微博的开发，我们当时使用了有道自己做的“BigTable”— OMAP来存储微博数据，那个时候才发现，其实Key-Value这种简单的存储也能搞定微博这类不太简单的存储逻辑。

相比MYSQL，当数据量上千万后，NOSQL的优势体现出来了：对于海量数据，NOSQL在存取速度上没有任何影响，另外，天生的多备份和分布式，也说数据安全和扩容变得异常容易。

后来我从后台转做iOS端的开发，我就尝试了在iOS端直接使用Key-Value式的存储。经过在粉笔网、猿题库、小猿搜题三个客户端中的尝试后，我发现Key-Value式的存储不但完全能够满足大多数移动端开发的需求，而且非常适合移动端采用。主要原因是：移动端存储的数据量不会很大：

 * 如果是单机的应用（例如效率工具Clear），用户自己一个人创建的数据最多也就上万条。
 * 如果是有服务端的应用（例如网易新闻，微博），那移动端通常不会保存全量的数据，每次会从服务器上获取数据，本地只是做一些内容的缓存而已，所以也不会有很大的数据量。

如果数据量不大的话，那么在iOS端使用最简单直接的Key-Value存储就能带来开发上的效率优势。它能保证：

 1. Model层的代码编写简单，易于测试。
 2. 由于Value是JSON格式，所以在做Model字段更改时，易于扩展和兼容。

在存储引擎上，2年前我直接选择了Sqlite当做存储引擎，相当于每个数据库表只有Key，Value两个字段。后来，随着LevelDB的流行，业界也有一些应用采用了LevelDB来做iOS端的Key-Value存储引擎，例如开源的[ViewFinder](https://github.com/viewfinderco/viewfinder)。

因为LevelDB本身并不是为移动端设计的，我担心它过于占用内存，另外我自己写的基于Sqlite的Key-Value存储用着也没有什么问题，所以我也就一直没有更换成LevelDB。


"Talk is cheap, show me the code”，这就是我基于FMDB封装的一个基于Sqlite的轻量级的Key-Value存储的源代码，以下是一个简单的使用示例：

```
    NSString *tableName = @"user_table";
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"test.db"];
    [store createTableWithName:tableName];
    NSString *key = @"1";
    NSDictionary *user = @{@"id": @1, @"name": @"tangqiao", @"age": @30};
    [store putObject:user withId:key intoTable:tableName];
    
    NSDictionary *queryUser = [store getObjectById:key fromTable:tableName];
    NSLog(@"query data result: %@", queryUser);

```
