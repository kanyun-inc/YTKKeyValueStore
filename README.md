
## 前言

还记得大学刚学数据库那会儿，天真地以为世界上所有的存储都需要用数据库来做。后来毕业后，正值NOSQL流行，那时我在网易参与了网易微博的开发，我们当时使用了有道自己做的“BigTable”— OMAP来存储微博数据，那个时候才发现，其实Key-Value这种简单的存储也能搞定微博这类不太简单的存储逻辑。

相比MYSQL，当数据量上千万后，NOSQL的优势体现出来了：对于海量数据，NOSQL在存取速度上没有任何影响，另外，天生的多备份和分布式，也说数据安全和扩容变得异常容易。

## iOS端的尝试

后来我从后台转做iOS端的开发，我就尝试了在iOS端直接使用Key-Value式的存储。经过在粉笔网、猿题库、小猿搜题三个客户端中的尝试后，我发现Key-Value式的存储不但完全能够满足大多数移动端开发的需求，而且非常适合移动端采用。主要原因是：移动端存储的数据量不会很大：

 * 如果是单机的应用（例如效率工具Clear），用户自己一个人创建的数据最多也就上万条。
 * 如果是有服务端的应用（例如网易新闻，微博），那移动端通常不会保存全量的数据，每次会从服务器上获取数据，本地只是做一些内容的缓存而已，所以也不会有很大的数据量。

如果数据量不大的话，那么在iOS端使用最简单直接的Key-Value存储就能带来开发上的效率优势。它能保证：

 1. Model层的代码编写简单，易于测试。
 2. 由于Value是JSON格式，所以在做Model字段更改时，易于扩展和兼容。

## 实现方案

在存储引擎上，2年前我直接选择了Sqlite当做存储引擎，相当于每个数据库表只有Key，Value两个字段。后来，随着LevelDB的流行，业界也有一些应用采用了LevelDB来做iOS端的Key-Value存储引擎，例如开源的[ViewFinder](https://github.com/viewfinderco/viewfinder)。

因为LevelDB本身并不是为移动端设计的，我担心它过于占用内存，我自己也没有看到业界有在移动端针对LevelDB做很详细的测试，连LevelDB的iOS端移植都不是官方做的。加上我自己写的基于Sqlite的Key-Value存储用着也没有什么问题，所以我也就一直没有更换成LevelDB。

## 开源

经过两年的使用和测试，我认为它非常好用，而且代码也非常简单，只有不到400行。所以现在开源分享给大家，这个项目叫`YTKKeyValueStore`，项目在[这里](https://github.com/yuantiku/YTKKeyValueStore)。以下是一个简单的使用示例：

```
YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"test.db"];
NSString *tableName = @"user_table";
[store createTableWithName:tableName];
// 保存
NSString *key = @"1";
NSDictionary *user = @{@"id": @1, @"name": @"tangqiao", @"age": @30};
[store putObject:user withId:key intoTable:tableName];
// 查询
NSDictionary *queryUser = [store getObjectById:key fromTable:tableName];
NSLog(@"query data result: %@", queryUser);
```

## 集成说明

使用本项目，你需要将开源代码中的`YTKKeyValueStore.h`和`YTKKeyValueStore.m`添加到你的工程中，并且在工程设置的`Link Binary With Libraries`中，增加`libsqlite3.dylib`，如下图所示：

![](http://blog.devtang.com/images/key-value-store-setup.jpg)

由于时间关系，当前还未提供Cocoapods方式集成。

## 使用说明

所有的接口都封装在`YTKKeyValueStore`类中。以下是一些常用方法说明。

### 打开（或创建）数据库

通过`initDBWithName`方法，即可在程序的`Document`目录打开指定的数据库文件。如果该文件不存在，则会创建一个新的数据库。

```
// 打开名为test.db的数据库，如果该文件不存在，则创新一个新的。
YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"test.db"];
```

### 创建数据库表

通过`createTableWithName`方法，我们可以在打开的数据库中创建表，如果表名已经存在，则会忽略该操作。如下所示：

```
YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"test.db"];
NSString *tableName = @"user_table";
// 创建名为user_table的表，如果已存在，则忽略该操作
[store createTableWithName:tableName];
```

### 读写数据

`YTKKeyValueStore`类提供key-value的存储接口，存入的所有数据需要提供key以及其对应的value，读取的时候需要提供key来获得相应的value。

`YTKKeyValueStore`类支持的value类型包括：NSString, NSNumber, NSDictionary和NSArray，为此提供了以下接口：

```
- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;
- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;
- (void)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;
```

与此对应，有以下value为NSString, NSNumber, NSDictionary和NSArray的读取接口：

```
- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;
- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;
- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName;
```

### 删除数据接口

`YTKKeyValueStore`提供了以下接口用于删除数据。

```
// 清除数据表中所有数据
- (void)clearTable:(NSString *)tableName;

// 删除指定key的数据
- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

// 批量删除一组key数组的数据
- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

// 批量删除所有带指定前缀的数据
- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;
```

### 更多接口

`YTKKeyValueStore`还提供了以下接口来获取表示内部存储的key-value对象。

```
// 获得指定key的数据
- (YTKKeyValueItem *)getYTKKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName;
// 获得所有数据
- (NSArray *)getAllItemsFromTable:(NSString *)tableName;
```

由于`YTKKeyValueItem`类带有`createdTime`字段，可以获得该条数据的插入（或更新）时间，以便上层做复杂的处理（例如用来做缓存过期逻辑）。

## 协议

YTKKeyValueStore 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。

## 其它

两年前写过不少测试用例，后来给弄丢了，所以现在开项项目中还没有测试用例。由于时间关系，更详细的使用说明稍后会更新到项目中。
