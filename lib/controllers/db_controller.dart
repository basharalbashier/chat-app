import 'dart:convert';
import 'dart:io';

import 'package:chat/controllers/signup_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test_client/test_client.dart';

import '../helpers/constant.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    debugPrint('initlizeing..');
    _database = await initDB();
    return _database!;
  }

  String createTableString =
      'CREATE TABLE info (id INTEGER PRIMARY KEY AUTOINCREMENT,uid Text, name TEXT, email TEXT,photourl TEXT)';

  String messagesTable =
      'CREATE TABLE info (id INTEGER PRIMARY KEY AUTOINCREMENT, channel TEXT, content TEXT,sender TEXT,sent_to TEXT,sent_at TEXT,seen_at TEXT,seen_by TEXT,group TEXT,deleted TEXT,replayto TEXT)';

  initDB() async {
    if (Platform.isAndroid || Platform.isIOS) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, "chat.db");
      return await openDatabase(path, version: 1, onOpen: (db) {},
          onCreate: (Database db, int version) async {
        await db.execute(createTableString);
      });
    }
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      Directory dir = await getApplicationDocumentsDirectory();
      var databaseFactory = databaseFactoryFfi;
      String path = join(dir.path, "chat.db");
      var db = await databaseFactory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
$createTableString
    ''');
              await db.execute('''
$messagesTable
    ''');
            },
          ));

      return db;
    }
  }

  Future<User> getMe() async {
    final db = await database;
    var result = await db.rawQuery("SELECT * FROM info");
    if (result.isEmpty) return User(name: '');
    Map<String, dynamic> data = Map.of(result[0]);
    var user = User.fromJson(data, Protocol());
    await client.userEndPoint.store(user);
    LoginController().me.value = user;
    return user;
  }

  addMe(User user) async {
    final db = await database;
    db.rawDelete("Delete from info WHERE id=1");
    var raw = await db.rawInsert(
        "INSERT Into info (id,uid,name,email,photourl)"
        " VALUES (?,?,?,?,?)",
        [user.id, user.uid, user.name, user.email, user.photourl]);
    var userFromHere = await getMe();
    await client.userEndPoint.store(userFromHere);
    return raw;
  }

  // showToast(a, e, la) {
  //   Fluttertoast.showToast(
  //       msg: la ? a : e,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 5,
  //       backgroundColor: Colors.pink,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  // updateLocation(late, longe, la) async {
  //   final db = await database;

  //   await db.rawUpdate('''
  //   UPDATE info
  //   SET late = ?, longe = ?
  //   WHERE id = ?
  //   ''', [late.toString(), longe.toString(), 1]);
  //   showToast(
  //       'تم تخزين نقطة التوصيل يمكنك الشراء وسيتم توجيه التوصيل لهذا الموقع',
  //       'The delivery point has been stored, you can buy and the delivery will be directed to this location',
  //       la);
  // }

//   inOrder(i) async {
//     final db = await database;

//     await db.rawUpdate('''
//     UPDATE info
//     SET inorder = ?
//     WHERE id = ?
//     ''', [i, 1]);
//   }

//   // add_point(la) async {
//   //   final db = await database;

//   //   var date = DateFormat("dd-MM-yyyy").format(DateTime.now());
//   //   db.rawQuery("SELECT * FROM info WHERE id=1 ").then((value) async {
//   //     if (value.isNotEmpty && value[0]['lastup'] != date) {
//   //       int i = (value[0]['points'] == null
//   //               ? 0
//   //               : int.parse(value[0]['points'].toString())) +
//   //           1;
//   //       db.rawUpdate('''
//   //   UPDATE info
//   //   SET points = ?, lastup = ?
//   //   WHERE id = ?
//   //   ''', [i, date, 1]);
//   //       showToast('رائع ! تم تاكيد نقطة اليوم',
//   //           'Gorgeous! Today\'s point confirmed', la);
//   //     } else {
//   //       showToast('عذرا ! تم تاكيد نقطة اليوم بالفعل',
//   //           'Oops ! Today\'s point has already been confirmed', la);
//   //     }
//   //   });
//   // }

//   addLastUpdate() async {
//     var date = DateFormat("dd-MM-yyyy").format(DateTime.now());
//     final db = await database;
//     db.rawDelete("Delete from date");
//     var raw = await db.rawInsert(
//         "INSERT Into date (id,date)"
//         " VALUES (?,?)",
//         [
//           1,
//           date,
//         ]);

//     return raw;
//   }

//   Future getLastUpdate() async {
//     final db = await database;
//     var result = await db.rawQuery("SELECT * FROM date  ");
//     // WHERE job = '%${search}%' OR joba = '${search}' OR jobb = '${search}' OR jobc = '${search}' ORDER BY distance;

//     if (result.isEmpty) return 0;

//     return result[0];
//   }

//   Future getall(String url, la) async {
//     getLastUpdate().then((value) async {
//       if (value == 0 ||
//           value['date'] != DateFormat("dd-MM-yyyy").format(DateTime.now())) {
//         try {
//           final result = await InternetAddress.lookup('example.com');
//           if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//             // print('connected');
//             try {
//               var response = await http
//                   .post(Uri.parse("$url/d/users/getall.php"), body: {});

//               if (response.statusCode != 200) {
//                 print(response.statusCode);
//               } else {
//                 List<dynamic> cat = json.decode(response.body);
//                 DBProvider.db.getAllJ().then((value) async {
//                   if (value.length != cat.length) {
//                     await DBProvider.db.deleteAll();

//                     cat.forEach((value) async {
//                       Client item = Client(
//                           id: value['id'].toString(),
//                           name: value['job'],
//                           jobe: value['jobe'],
//                           cat: value['cat'],
//                           da: value['da'],
//                           de: value['de']);

//                       await DBProvider.db.newCat(item);
//                     });
//                   }
//                   getallStoreData(url, la);
//                   addLastUpdate();
//                 });
//               }
//             } catch (e) {
//               if (kDebugMode) {
//                 print(e);
//               }
//               getall(url, la);
//             }
//           }
//         } on SocketException catch (_) {
//           print('not connected');
//         }
//       }
//       getWorkers(url, '0');
//       add_offers(url);
//     });
//   }

//   Future getWorkers(String url, [String? id]) async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         if (kDebugMode) {
//           print('connected');
//         }
//         try {
//           var response =
//               await http.post(Uri.parse("$url/d/users/all_wo.php"), body: {
//             "id": id,
//           });
//           // print(response.body);

//           if (response.statusCode >= 400) {
//             if (kDebugMode) {
//               print('object');
//             }
//           } else {
//             await DBProvider.db.deleteAllWorkers();
//             //var long2 = double.parse($group1);
//             List<dynamic> cat = json.decode(response.body);

//             cat.forEach((value) async {
//               Client item = Client(
//                 id: value['id'].toString(),
//                 name: value['name'].toString(),
//                 namee: value['namee'].toString(),
//                 number: value['phone'].toString(),
//                 late: value['late'].toString(),
//                 longe: value['longe'].toString(),
//                 job: value['job'].toString(),
//                 joba: value['joba'].toString(),
//                 jobb: value['jobb'].toString(),
//                 img: value['img'],
//                 jobc: value['jobc'].toString(),
//                 hist: value['hist'].toString(),
//               );

//               // print(
//               //     '${item.id}--${item.name}--${item.number}--${item.late}--${item.longe}--${item.job}--${item.joba}--${item.jobb}--${item.jobc}--${item.distance}------${item.img}');

//               await DBProvider.db.newWorker(item);
//             });
//           }
//         } catch (e) {
//           if (kDebugMode) {
//             print(e);
//           }
//         }

//         //  var urly = "$url/d/users/getall.php";
//         // var response = await http.post(Uri.parse(urly), body: {

//       }
//     } on SocketException catch (_) {
//       if (kDebugMode) {
//         print('not connected');
//       }
//     }
//   }

//   Future<List<dynamic>> getAllOffers(int id) async {
//     print('caled');
//     final db = await database;
//     // var oo = await db.query("ser_of");
//     var res = id != 0
//         ? await db.query("ser_of",
//             orderBy: "liked" + " DESC",
//             where: "category_id = ?",
//             whereArgs: [id])
//         : await db.query("ser_of", orderBy: "liked" + " DESC", limit: 10);

// //  print(oo);
//     return res;
//   }

//   add_offers(url) async {
//     final db = await database;
//     db.rawDelete("Delete from ser_of");
// //    name TEXT, description TEXT,price TEXT, category_id INTEGER,created TEXT,modified TEXT, job_id INTEGER, worker_id INTEGER,picn INTEGER,liked INTEGER,see INTEGER)');

//     try {
//       var response =
//           await http.post(Uri.parse("$url/d/users/get_all_of.php"), body: {});

//       // print('-----${jsonDecode(response.body)}');

//       for (var i in jsonDecode(response.body)) {
//         var raw = await db.rawInsert(
//             "INSERT Into ser_of (id,name,phone,description,price,category_id,created,modified,job_id,worker_id,picn,liked,see,vdio)"
//             " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//             [
//               i['id'],
//               i['name'],
//               i['phone'],
//               i['description'],
//               i['price'],
//               i['category_id'],
//               i['created'],
//               i['modified'],
//               i['job_id'],
//               i['worker_id'],
//               i['picn'],
//               i['liked'],
//               i['see'],
//               i['vdio'],
//             ]);
//       }
//     } catch (e) {}
//   }

//   add_to_liked(liked) async {
//     final db = await database;
//     var res = await db.query("like", where: "id = ?", whereArgs: [liked['id']]);

//     if (res.isEmpty) {
//       var raw = await db.rawInsert(
//           "INSERT Into like (id,name,phone,description,price,category_id,created,modified,job_id,worker_id,picn,liked,see)"
//           " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
//           [
//             liked['id'],
//             liked['name'],
//             liked['phone'],
//             liked['description'],
//             liked['price'],
//             liked['category_id'],
//             liked['created'],
//             liked['modified'],
//             liked['job_id'],
//             liked['worker_id'],
//             liked['picn'],
//             liked['liked'],
//             liked['see'],
//           ]);
//     }

//     print('added');
//     // return raw;
//   }

//   Future<List<dynamic>> get_all_liked() async {
//     final db = await database;
//     var res = await db.query("like");

//     return res;
//   }

//   add_to_saved(liked) async {
//     final db = await database;

//     var raw = await db.rawInsert(
//         "INSERT Into saved (id,name,phone,description,price,category_id,created,modified,job_id,worker_id,picn,liked,see)"
//         " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
//         [
//           liked['id'],
//           liked['name'],
//           liked['phone'],
//           liked['description'],
//           liked['price'],
//           liked['category_id'],
//           liked['created'],
//           liked['modified'],
//           liked['job_id'],
//           liked['worker_id'],
//           liked['picn'],
//           liked['liked'],
//           liked['see'],
//         ]);

//     return raw;
//   }

//   newWorker(Client newPro) async {
//     final db = await database;
//     await db.rawInsert(
//         "INSERT Into workers (id,name,namee,phone,late,longe,job,joba,jobb,jobc,distance,img,hist)"
//         " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
//         [
//           newPro.id,
//           newPro.name,
//           newPro.namee,
//           newPro.number,
//           newPro.late,
//           newPro.longe,
//           newPro.job,
//           newPro.joba,
//           newPro.jobb,
//           newPro.jobc,
//           newPro.distance,
//           newPro.img,
//           newPro.hist
//         ]);
//   }

//   newCat(Client newPro) async {
//     final db = await database;
//     var raw = await db.rawInsert(
//         "INSERT Into jobs (id,name,jobe,cat,da,de)"
//         " VALUES (?,?,?,?,?,?)",
//         [
//           newPro.id,
//           newPro.name,
//           newPro.jobe,
//           newPro.cat,
//           newPro.da,
//           newPro.de
//         ]);

//     return raw;
//   }

//   Future<List<Client>> getAllJobs(int id) async {
//     final db = await database;
//     var res = await db.query("jobs", where: "cat = ?", whereArgs: [id]);

//     List<Client> list =
//         res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
//     return list;
//   }

//   Future<List<Client>> getAllJ() async {
//     final db = await database;
//     var res = await db.query("jobs");

//     List<Client> list =
//         res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
//     return list;
//   }

//   deleteAllWorkers() async {
//     final db = await database;
//     db.rawDelete("Delete from workers");
//   }

//   deleteAll() async {
//     final db = await database;
//     db.rawDelete("Delete from jobs");
//     // db.rawDelete("Delete from workers");
//   }

//   Future<List<Client>> searchJobMap(String search) async {
//     Database db = await database;

//     var result = await db.rawQuery(
//         "SELECT * FROM jobs WHERE name LIKE '%${search}%' OR jobe LIKE '%${search}%' OR de LIKE '%${search}%' OR da LIKE '%${search}%' ");
//     List<Client> list =
//         result.isNotEmpty ? result.map((c) => Client.fromMap(c)).toList() : [];
//     // print(result.length - 8);
//     return list;
//   }

//   Future<List<Client>> searchJob(String search) async {
//     var searchResults =
//         await searchJobMap(search); // Get 'Map List' from database
//     // print(searchResults.length);
//     // print(searchResults.toString());
//     int count =
//         searchResults.length; // Count the number of map entries in db table

//     List<Client> memberList = [];
//     // For loop to create a 'Member List' from a 'Map List'
//     for (int i = 0; i < count; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(searchResults[i]);
//     }

//     // print("completed for loop");
//     return memberList;
//   }

//   Future<List<Client>> searchOfferMap(String search) async {
//     Database db = await database;

//     var result = await db.rawQuery(
//         "SELECT * FROM ser_of WHERE name LIKE '%${search}%' OR description LIKE '%${search}%'  ");
//     List<Client> list =
//         result.isNotEmpty ? result.map((c) => Client.fromMap(c)).toList() : [];
//     print(result.length - 8);
//     return list;
//   }

//   Future<List<Client>> searchOffer(String search) async {
//     var searchResults =
//         await searchOfferMap(search); // Get 'Map List' from database
//     // print(searchResults.length);
//     // print(searchResults.toString());
//     int count =
//         searchResults.length; // Count the number of map entries in db table

//     List<Client> memberList = [];
//     // For loop to create a 'Member List' from a 'Map List'
//     for (int i = 0; i < count; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(searchResults[i]);
//     }

//     // print("completed for loop");
//     return memberList;
//   }

//   //................................................
//   int n = 0;
//   Future getallStoreData(String url, la) async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         // print('connected');
//         try {
//           await http
//               .get(Uri.parse("$url/sh/getall.php"))
//               .then((category) async {
//             if (category.statusCode != 200) {
//               // print(response.statusCode);
//             } else {
//               final db = await database;
//               await db.rawDelete("Delete  from categories");
//               List<dynamic> cate = json.decode(category.body);

//               for (var i in cate) {
//                 await db.rawInsert(
//                     "INSERT Into categories (id,name,namea)"
//                     " VALUES (?,?,?)",
//                     [
//                       i['id'],
//                       i['name'],
//                       i['namea'],
//                     ]).then((value) {
//                   // print(value);
//                 });
//                 // print('New order added :--------------------------$raw');

//               }
//               try {
//                 await http.get(Uri.parse("$url/sh/pro.php")).then((pro) async {
//                   if (pro.statusCode != 200) {
//                     // print(response.statusCode);
//                   } else {
//                     await http
//                         .get(Uri.parse("$url/sh/stores.php"))
//                         .then((stores) async {
//                       if (stores.statusCode != 200) {
//                         // print(response.statusCode);
//                       } else {
//                         final db = await database;

//                         await db.rawDelete("Delete  from stores");
//                         List<dynamic> storesList = json.decode(stores.body);

//                         for (var i in storesList) {
//                           await db.rawInsert(
//                               "INSERT Into stores (id,name,namee,cat,rate,phone,created)"
//                               " VALUES (?,?,?,?,?,?,?)",
//                               [
//                                 i['id'],
//                                 i['name'],
//                                 i['namee'],
//                                 i['cat'],
//                                 i['rate'],
//                                 i['phone'],
//                                 i['created'],
//                               ]).then((value) {
//                             if (kDebugMode) {
//                               print(i['name']);
//                             }
//                           });
//                         }
//                       }
//                     }).then((value) async {
//                       await http
//                           .get(Uri.parse("$url/sh/rates.php"))
//                           .then((stores) async {
//                         if (stores.statusCode != 200) {
//                           // print(response.statusCode);
//                         } else {
//                           final db = await database;

//                           await db.rawDelete("Delete  from rates");
//                           List<dynamic> storesList = json.decode(stores.body);

//                           for (var i in storesList) {
//                             await db.rawInsert(
//                                 "INSERT Into rates (id,type,com,rate,name,phone,tid)"
//                                 " VALUES (?,?,?,?,?,?,?)",
//                                 [
//                                   i['id'],
//                                   i['type'],
//                                   i['com'],
//                                   i['rate'],
//                                   i['name'],
//                                   i['phone'],
//                                   i['tid'],
//                                 ]).then((value) {});
//                           }
//                         }
//                       });
//                     });
//                     await db.rawDelete("Delete  from products");

//                     List<dynamic> cate = json.decode(pro.body);
//                     for (int i = 0; i <= cate.length; i++) {
//                       await db.rawInsert(
//                           "INSERT Into products (id,name,description,price,category_id,short,brand,number,unit,status,del,gua,liked,ordered,store_id,picn,blocked,porm,vdio,stat)"
//                           " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//                           [
//                             cate[i]['id'],
//                             cate[i]['name'],
//                             cate[i]['description'],
//                             cate[i]['price'],
//                             cate[i]['category_id'],
//                             cate[i]['short'],
//                             cate[i]['brand'],
//                             cate[i]['number'],
//                             cate[i]['unit'],
//                             cate[i]['status'],
//                             cate[i]['del'],
//                             cate[i]['gua'],
//                             cate[i]['liked'],
//                             cate[i]['ordered'],
//                             cate[i]['store_id'],
//                             cate[i]['picn'],
//                             cate[i]['blocked'],
//                             cate[i]['porm'],
//                             cate[i]['vdio'],
//                             cate[i]['stat']
//                           ]).then((x) async {
//                         if (cate[i]['porm'] == '1') {
//                           if (kDebugMode) {
//                             print(i);
//                           }

//                           showNotificationForStore(cate[i], la, i);
//                         }
//                       });
//                     }
//                     print('im here');
//                   }
//                 });
//               } catch (e) {}
//             }
//           });
//         } catch (e) {
//           print(e);
//           getallStoreData(url, la);
//         }
//       }
//     } on SocketException catch (_) {
//       print('not connected');
//     }
//   }

//   Future<List<dynamic>> catList() async {
//     Database db = await this.database;
//     var result = await db.rawQuery("SELECT * FROM categories  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(result[i]);
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> likedList() async {
//     Database db = await this.database;
//     var result = await db.rawQuery("SELECT * FROM liked  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(result[i]);
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> proList() async {
//     Database db = await this.database;
//     var result = await db.rawQuery("SELECT * FROM products  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(result[i]);
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> viewed() async {
//     Database db = await database;
//     var result =
//         await db.rawQuery("SELECT * FROM view ORDER BY rank DESC LIMIT 10");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       // print("for loop working: ${result[i]['rank']}");
//       memberList.add(result[i]);
//     }
//     return memberList;
//   }

//   increaseCat(late, longe, la) async {
//     final db = await database;

//     await db.rawUpdate(
//         'UPDATE product SET price = price + 50. Example 2 (for a specific row): UPDATE product SET price = price + 50 WHERE id = 1');
//   }

//   Future<List<dynamic>> simillerPro(int id, int exep) async {
//     Database db = await database;
//     var result =
//         await db.rawQuery("SELECT * FROM products WHERE category_id=$id  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       if (result[i]['store_id'] != exep) {
//         memberList.add(result[i]);
//       }
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> simillerStore(int id, int exep) async {
//     Database db = await database;
//     var result = id != 0
//         ? await db.rawQuery("SELECT * FROM stores WHERE cat=$id  ")
//         : await db.rawQuery("SELECT * FROM stores ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       if (result[i]['id'] != exep) {
//         memberList.add(result[i]);
//       }
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> porm() async {
//     Database db = await this.database;
//     var result = await db.rawQuery("SELECT * FROM products  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       if (result[i]['porm'] == 1) {
//         memberList.add(result[i]);
//         //  print("for loop working: ${i + 1}");

//       }
//     }
//     return memberList;
//   }

//   Future<List<Map<String, dynamic>>> searchProductMap(
//       String search, int id) async {
//     Database db = await database;

//     var result = id == 0
//         ? await db.rawQuery(
//             "SELECT * FROM products WHERE name LIKE '%${search}%' OR description LIKE '%${search}%' OR short LIKE '%${search}%' OR brand LIKE '%${search}%' ")
//         : await db.rawQuery(
//             "SELECT * FROM products WHERE category_id=$id AND  (name LIKE '%${search}%' OR description LIKE '%${search}%' OR short LIKE '%${search}%' OR brand LIKE '%${search}%') ");
//     // print("workers is working? $result");
//     print(result.length - 8);
//     return result;
//   }

//   Future<List<dynamic>> searchProduct(String search, int id) async {
//     var searchResults =
//         await searchProductMap(search, id); // Get 'Map List' from database
//     // print(searchResults.length);
//     // print(searchResults.toString());
//     int count =
//         searchResults.length; // Count the number of map entries in db table

//     List memberList = [];
//     // For loop to create a 'Member List' from a 'Map List'
//     for (int i = 0; i < count; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(searchResults[i]);
//     }

//     // print("completed for loop");
//     return memberList;
//   }

//   addToCart(pro, i) async {
//     Database db = await database;
//     await db.query("cart", where: "id = ?", whereArgs: [pro['id']]).then(
//         (value) async {
//       if (kDebugMode) {
//         print(value);
//       }
//       if (value.isEmpty) {
//         await db.rawInsert(
//             "INSERT Into cart (id,name,description,price,short,brand,number,unit,status,del,gua,liked,ordered,store_id,picn)"
//             " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//             [
//               pro['id'],
//               pro['name'],
//               pro['description'],
//               pro['price'],
//               pro['short'],
//               pro['brand'],
//               i,
//               pro['unit'],
//               pro['status'],
//               pro['del'],
//               pro['gua'],
//               pro['liked'],
//               pro['ordered'],
//               pro['store_id'],
//               pro['picn'],
//             ]).then((value) {
//           print(value);
//         });
//       }
//     });
//   }

//   addToSearch(text) async {
//     Database db = await database;

//     await db
//         .rawQuery("SELECT * FROM search WHERE text LIKE '%${text}%' ")
//         .then((value) async {
//       if (value.isEmpty) {
//         var result = await db.rawQuery("SELECT * FROM search");
//         await db.rawInsert(
//             "INSERT Into search (id,text)"
//             " VALUES (?,?)",
//             [
//               result.length + 1,
//               text,
//             ]);
//       } else {
//         print(value);
//       }
//     });
//   }

//   addToVie(pro) async {
//     Database db = await database;
//     // db.rawDelete("Delete  from view");

//     await db.query("view", where: "id = ?", whereArgs: [pro['id']]).then(
//         (value) async {
//       var result = await db.rawQuery("SELECT * FROM view  ");
//       // for(var i in result){
//       //   print(i['rank']);

//       // }
//       if (value.isEmpty) {
//         await db.rawInsert(
//             "INSERT Into view (id,name,description,price,category_id,short,brand,number,unit,status,del,gua,liked,ordered,store_id,picn,rank,vdio,stat)"
//             " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//             [
//               pro['id'],
//               pro['name'],
//               pro['description'],
//               pro['price'],
//               pro['category_id'],
//               pro['short'],
//               pro['brand'],
//               pro['number'],
//               pro['unit'],
//               pro['status'],
//               pro['del'],
//               pro['gua'],
//               pro['liked'],
//               pro['ordered'],
//               pro['store_id'],
//               pro['picn'],
//               result.length + 1,
//               pro['vdio'],
//               pro['stat'],
//             ]);
//       } else {
//         await db
//             .rawDelete("DELETE FROM view WHERE id = ${pro['id']}")
//             .then((value) async {
//           await db.rawInsert(
//               "INSERT Into view (id,name,description,price,category_id,short,brand,number,unit,status,del,gua,liked,ordered,store_id,picn,rank,vdio,stat)"
//               " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//               [
//                 pro['id'],
//                 pro['name'],
//                 pro['description'],
//                 pro['price'],
//                 pro['category_id'],
//                 pro['short'],
//                 pro['brand'],
//                 pro['number'],
//                 pro['unit'],
//                 pro['status'],
//                 pro['del'],
//                 pro['gua'],
//                 pro['liked'],
//                 pro['ordered'],
//                 pro['store_id'],
//                 pro['picn'],
//                 result.length + 1,
//                 pro['vdio'],
//                 pro['stat'],
//               ]);
//         });
//       }
//     });
//   }

//   addLiked(pro, url) async {
//     Database db = await this.database;
//     await db.query("liked", where: "id = ?", whereArgs: [pro['id']]).then(
//         (value) async {
//       if (value.isEmpty) {
//         await db.query("info", where: "id = ?", whereArgs: [pro['id']]).then(
//             (v) async {
//           if (v.isEmpty) {
//             try {
//               await http.post(Uri.parse("$url/sh/like_pro.php"), body: {
//                 "id": '${pro['id']}',
//               }).then((value) async {
//                 await db.rawInsert(
//                     "INSERT Into info (id,name,phone)"
//                     " VALUES (?,?,?)",
//                     [
//                       pro['id'],
//                       pro['name'],
//                       pro['short'],
//                     ]);
//               });
//             } catch (e) {}
//           }
//         });

//         await db.rawInsert(
//             "INSERT Into liked (id,name,description,price,category_id,short,brand,number,unit,status,del,gua,liked,ordered,store_id,picn,vdio,stat)"
//             " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//             [
//               pro['id'],
//               pro['name'],
//               pro['description'],
//               pro['price'],
//               pro['category_id'],
//               pro['short'],
//               pro['brand'],
//               pro['number'],
//               pro['unit'],
//               pro['status'],
//               pro['del'],
//               pro['gua'],
//               pro['liked'],
//               pro['ordered'],
//               pro['store_id'],
//               pro['picn'],
//               pro['vdio'],
//               pro['stat'],
//             ]);
//       } else {
//         await db.rawDelete("DELETE FROM liked WHERE id = ${pro['id']}");
//       }
//     });
//   }

//   Future<List<Map<String, dynamic>>> searchCartMap(String search) async {
//     Database db = await this.database;

//     var result = await db.rawQuery(
//         "SELECT * FROM cart WHERE name LIKE '%${search}%' OR description LIKE '%${search}%' OR short LIKE '%${search}%'  ");
//     return result;
//   }

//   Future<List<dynamic>> searchCart(String search) async {
//     var searchResults =
//         await searchCartMap(search); // Get 'Map List' from database
//     // print(searchResults.length);
//     // print(searchResults.toString());
//     int count =
//         searchResults.length; // Count the number of map entries in db table

//     List memberList = [];
//     // For loop to create a 'Member List' from a 'Map List'
//     for (int i = 0; i < count; i++) {
//       // print("for loop working: ${i + 1}");
//       memberList.add(searchResults[i]);
//     }

//     return memberList;
//   }

//   clearCart() async {
//     final db = await database;
//     db.rawDelete("Delete  from cart");
//   }

//   Future ifLiked(int id) async {
//     Database db = await this.database;
//     var res = await db.query("liked", where: "id = ?", whereArgs: [id]);

//     List<dynamic> memberList = res;
//     if (res.isEmpty) {
//       return 0;
//     }

//     return memberList;
//   }

//   Future myRev(int id) async {
//     Database db = await this.database;
//     var res = await db.query("rates", where: "phone = ?", whereArgs: [id]);

//     List<dynamic> memberList = res;

//     return memberList;
//   }

//   Future storesPro(int id) async {
//     Database db = await this.database;
//     var res =
//         await db.query("products", where: "store_id = ?", whereArgs: [id]);
//     // print('$res-----------------');
//     var memberList = res;

//     return memberList;
//   }

//   Future<List<dynamic>> recentAdded() async {
//     Database db = await this.database;
//     var result =
//         await db.rawQuery("SELECT * FROM products ORDER BY id DESC LIMIT 10 ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       memberList.add(result[i]);
//       //  print("for loop working: ${i + 1}");

//     }
//     return memberList;
//   }

//   Future<List<dynamic>> best() async {
//     Database db = await this.database;
//     var result = await db
//         .rawQuery("SELECT * FROM products ORDER BY ordered DESC LIMIT 10 ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       memberList.add(result[i]);
//       //  print("for loop working: ${i + 1}");

//     }
//     return memberList;
//   }

//   Future<List<dynamic>> liked() async {
//     Database db = await this.database;
//     var result = await db
//         .rawQuery("SELECT * FROM products ORDER BY liked DESC LIMIT 10 ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       memberList.add(result[i]);
//       //  print("for loop working: ${i + 1}");

//     }
//     return memberList;
//   }

//   Future<List<dynamic>> all() async {
//     Database db = await database;
//     var result = await db.rawQuery("SELECT * FROM products  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       memberList.add(result[i]);
//       //  print("for loop working: ${i + 1}");

//     }
//     return memberList;
//   }

//   Future<List<dynamic>> allProVid() async {
//     Database db = await database;
//     var result = await db.rawQuery("SELECT * FROM products  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       if (result[i]['vdio'] != 'no') {
//         memberList.add(result[i]);
//       }
//     }
//     return memberList;
//   }

//   Future<List<dynamic>> getRates(phone) async {
//     Database db = await this.database;
//     var result = await db.rawQuery("SELECT * FROM rates  ");
//     List memberList = [];
//     for (int i = 0; i < result.length; i++) {
//       if (result[i]['phone'] == phone) {
//         memberList.add(result[i]);
//       }
//     }
//     return memberList;
//   }

//   Future<List<Map<String, dynamic>>> store(int id) async {
//     Database db = await this.database;
//     var res = await db.query("stores", where: "id = ?", whereArgs: [id]);

//     List<Map<String, dynamic>> memberList = res;

//     return memberList;
//   }
}
