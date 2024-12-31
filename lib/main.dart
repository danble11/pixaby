import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/const.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabyPage(),
    );
  }
}


class PixabyPage extends StatefulWidget {
  const PixabyPage({super.key});

  @override
  State<PixabyPage> createState() => _PixabyPageState();
}

class _PixabyPageState extends State<PixabyPage> {
  List imageList = [];

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=$apiKey&q=$text&image_type=photo&pretty=true&per_page=100',
    );
    imageList = response.data['hits'];
    print('Fetched images: ${response.data['hits']}');

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchImages('nature');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration:InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Search for images',
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onFieldSubmitted: (text){
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: imageList.length,
        itemBuilder: (context,index){
          Map<String,dynamic> image = imageList[index];
          return InkWell(
            onTap: () async{
              Directory dir = await getTemporaryDirectory();
              Response response = await Dio().get(
                image['webformatURL'],
                options: Options(
                  responseType: ResponseType.bytes,
                ),
              );

              File imageFile = await File('${dir.path}/image.png').writeAsBytes(response.data);
              XFile xFile = XFile(imageFile.path);
              await Share.shareXFiles([xFile]);
                
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  image['previewURL'],
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 14,
                        ),
                        Text(image['likes'].toString()),
                      ],
                    ),
                  ),
                )
              ],  
            ),
          );
        },
      ),
    );
  }
}


