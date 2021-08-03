import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  var resHere;

  Future<String> uploadImage(File filename, url) async {
    print(url);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    print(request);
    request.files.add(await http.MultipartFile.fromPath('model_pic', filename.path));
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      'connection': 'keep-alive'
    });
    var res = await request.send();
    
    res.stream.transform(utf8.decoder).listen((value) async{
      print('inside function');
      print(value.substring(6,value.indexOf(",")));
      var result = await fetchIngredients(value.substring(6,value.indexOf(",")));
      print(result);
    });

    return res.reasonPhrase;
  }


  upload(File imageFile) async {    
      
      var stream = new http.ByteStream(Stream.castFrom(imageFile.openRead()));
      // get file length
      var length = await imageFile.length();

      // string to uri
      var uri = Uri.parse("http://165.232.189.16/upload/");

      // create multipart request
      var request = new http.MultipartRequest("POST", uri);

      // multipart that takes file
      print("-------------------");
      var multipartFile = new http.MultipartFile('model_pic', stream, length,
          filename: basename(imageFile.path));

      // add file to multipart
      print("-------------------");
      request.files.add(multipartFile);

      // send
      var response = await request.send();
      print(response.statusCode);

      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });

    
    }

  Future fetchIngredients(id) async {

    final response = await http
        .get(Uri.parse('http://165.232.189.16/ingredients?id=$id'));
    print('http://165.232.189.16/ingredients?id=$id');
    print(response.statusCode);
    if (response.statusCode == 200) {
      // return Album.fromJson(jsonDecode(response.body));
      resHere = json.decode(response.body);
      print(resHere);
    } else {
      throw Exception('Failed to load album');
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter File Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Done")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("upload");
          var file = await ImagePicker().getImage(source: ImageSource.gallery);
          var res = await uploadImage(File(file.path), "http://165.232.189.16/upload/");
          print(res);

        },
        child: Icon(Icons.add),
      ),
    );
}
}