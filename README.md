# Kinto-iOS
A library that gives you access to the JSON storage service <a href="http://kinto.readthedocs.io/en/stable/"> Kinto </a>. For more information about Kitno and its features, see the public documentation.
### Getting Started
To get started with Kinto, see the <a href="http://kinto.readthedocs.io/en/stable/tutorials/index.html#tutorials"> tutorials </a>. You can use the Mozilla demo server, or set uo your own instance
Note: if you use Mozilla demo server, the records will be flushed every dat at 7:OO AM UTC

### Configuration

In your Appdelegate.swift:

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        KintoConfig.bucketName = "BUCKET_NAME"
        KintoConfig.url = "SERVER_URL"
        KintoConfig.username = "USERNAME"
        KintoConfig.password = "PASSWORD"

        return true
    }
```

### GET
<ul>
  
  
  <li> Get All Objects </li>
  
```Swift
    let query = KintoQuery(collectionName: "COLLECTION_NAME")
    query.findObjectsInBackground (completionBlock: (KintoQueryArrayResultBlock))
```

  <li> Get First Object </li>
  
```Swift
    let query = KintoQuery(collectionName: "COLLECTION_NAME")
    query.getFirstObject(completionBlock: KintoQueryObjectResultBlock)
```


<li> Get Object with ID </li>

```Swift
    query.getObjectWithId(kintoId: String>, completionBlock: (KintoQueryObjectResultBlock))
```

</ul>

### FILTERING: GET WHERE KEY

```Swift
    
        let query = KintoQuery(collectionName: String)
        
        query.whereKeyExists(recordName: String)
        query.whereKeyDoesNotExist(recordName: String)
        
        query.whereKey(recordName: String, equalTo: Any)
        query.whereKey(recordName: String, notEqualTo: Any)
        
        query.whereKey(recordName: String, contains: String)
        query.whereKey(recordName: String, containedIn: [Any])
        query.whereKey(recordName: String, notContainedIn: [Any])
        
        query.whereKey(recordName: String, lessThan: Any)
        query.whereKey(recordName: String, lessThanOrEqual: Any)
        
        query.whereKey(recordName: String, greaterThan: Any)
        query.whereKey(recordName: String, greaterThanOrEqual: Any)
        
        query.whereKey(recordName: String, hasPrefix: String)
        query.whereKey(recordName: String, hasSuffix: String)
    
```

### Include Key
 Make the query include `KintoObject`s that have a reference stored at the provided key. This has an effect similar to a join. The recordName must have the same name of the reference collection name.

```Swift
    let query = KintoQuery(collectionName: String)
    query.includeKey(recordName: String)
```

Example: 

```Swift
    let query = KintoQuery(collectionName: "car")
    query.includeKey(recordName: "user")
    query.getFirstObject { (object, error) in
            print("Car owner", (object["user"] as! [KintoObject])[0]["name"] as! String)
    }
```

### SAVE

```Swift
    KintoObject().saveInBackground(completionBlock: (KintoBooleanResultBlock))
```

### UPDATE

```Swift
    KintoObject().updateObject(completionBlock: (KintoBooleanResultBlock))
```

### DELETE

```Swift
    KintoObject().deleteInBackground(completionBlock: (KintoBooleanResultBlock))
```

### Paginating

```Swift
    let query = KintoQuery.init(collectionName: String)
    query.limit = Int
    query.findObjectsInBackground(completionBlock: (KintoQueryArrayResultBlock))
```
If there are more records for this collection than the limit, the query will provide nextPage

```Swift
    query.getNextPage(nextPageUrl: String, completionBlock: (KintoQueryArrayResultBlock))
```
### Counting

```Swift
    let query = KintoQuery(collectionName: String)
    query.countInBackground(completionBlock: KintoIntegerResultBlock)
```
### Sorting
<ul>
  <li> Ascending </li>
  
```Swift
    let query = KintoQuery(collectionName: String)
    query.order(byAscending: String)
```
  
  <li> Descending </li>
  
  ```Swift
    let query = KintoQuery(collectionName: String)
    query.order(byDescending: String)
```
  
</ul>
     
### Dependencies
We use the following libraries as dependencies inside of Kinto:
<ul>
  <li> <a href = "https://github.com/Alamofire/Alamofire"> Alamofire </a>, for HTTP networking. </li>
  <li> <a href= "https://github.com/SwiftyJSON/SwiftyJSON"> SwiftyJSON </a>, to deal with JSON data. </li>
</ul>

### How Do I Contribute?
<ul>
  <li>If you found a bug, open an issue.</li>
  <li>If you have a feature request, open an issue.</li>
  <li>If you want to contribute, submit a pull request.</li>
</ul>

### Perspectives
<ul>
  <li> Manage accounts (working on)</li>
  <li> Manage Attachements</li>
  <li> Manage Push Notifications</li>
</ul>

### License
  Copyright (c) 2017-present, Karizma, LTD.
  www.karizma.io
All rights reserved.
