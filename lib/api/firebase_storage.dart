
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageFirebase {

  static Reference   storage = FirebaseStorage.instance.ref().child('image_users/');
  static List<UploadTask> listUploads = List.empty();

  static Future<String> putImage(File image) async{

    UploadTask uploadTask = storage.child('${Uuid().v1()}').putFile(image);

    final StreamSubscription<TaskSnapshot> streamSubscription = uploadTask.snapshotEvents.listen((event) {

    });
    String url = await (await uploadTask).ref.getDownloadURL();
    streamSubscription.cancel();
    return url;
  }

}