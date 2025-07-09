import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class DaftarUserScreen extends StatelessWidget {
  const DaftarUserScreen({super.key});
  static const routeName = 'daftar-user-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar user'),
      ),
      body: FutureBuilder(
        future: getDataUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            // print(snapshot.error);
            return const Text('Terjadi keasalahan');
          }
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var singleData = snapshot.data?[index];
                return ListTile(
                  title: Text(singleData['title']),
                  subtitle: Text(singleData['body']),
                );
              });
        },
      ),
    );
  }

  Future<List> getDataUser() async {
    // Response res = await dio.get('https://jsonplaceholder.typicode.com/users');
    Response res = await dio.get('https://jsonplaceholder.typicode.com/posts');
    return res.data;
    // return [];
  }
}
