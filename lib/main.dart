import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musixMatch/trackDetails.dart';
import 'package:connectivity/connectivity.dart';

List<dynamic> topSongs;
bool _isLoading = true;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Tracks(),
      theme: ThemeData(primaryIconTheme: IconThemeData(color: Colors.black)),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Tracks extends StatefulWidget {
  @override
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  bool isNetwork = true;
  StreamSubscription<ConnectivityResult> subscription;
  bool dataResult;
  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          isNetwork = true;
        });
      } else {
        setState(() {
          isNetwork = false;
        });
      }
    });
    fetchAlbum();
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future fetchAlbum() async {
    final response = await http.get(
        "https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=API_KEY");

    if (response.statusCode == 200) {
      setState(() {
        var trackData = jsonDecode(response.body);
        topSongs = trackData['message']['body']['track_list'];
        _isLoading = false;
        print(trackData);
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              "Trending",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        body: isNetwork
            ? _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: topSongs == null ? 0 : topSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var song = topSongs[index]['track'];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TrackDetails(song['track_id'])));
                          },
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          leading: Icon(Icons.library_music),
                          title: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(song['track_name'])),
                                Flexible(
                                  child: Container(
                                    child: Text(
                                      song['artist_name'],
                                      textWidthBasis:
                                          TextWidthBasis.longestLine,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(song['album_name']),
                          // trailing: Text(song['artist_name']),
                        ),
                      );
                    },
                  )
            : Center(child: Text("No Internet Connection")));
  }
}
