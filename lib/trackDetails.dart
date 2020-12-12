import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

var songDetail;
var songlyrics;
bool _isLoading = true;

class TrackDetails extends StatefulWidget {
  final track_id;
  TrackDetails(this.track_id);

  @override
  _TrackDetailsState createState() => _TrackDetailsState();
}

class _TrackDetailsState extends State<TrackDetails> {
  bool isNetwork = true;
  StreamSubscription<ConnectivityResult> subscription;

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
    fetchAlbum(widget.track_id);
    fetchLyrics(widget.track_id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future fetchAlbum(track_id) async {
    final response = await http.get(
        "https://api.musixmatch.com/ws/1.1/track.get?track_id=" +
            track_id.toString() +
            "&apikey=API_KEY");

    if (response.statusCode == 200) {
      setState(() {
        var trackData = jsonDecode(response.body);
        songDetail = trackData['message']['body']['track'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future fetchLyrics(track_id) async {
    final response = await http.get(
        "https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=" +
            track_id.toString() +
            "&apikey=API_KEY");

    if (response.statusCode == 200) {
      setState(() {
        var trackData = jsonDecode(response.body);
        songlyrics = trackData['message']['body']['lyrics']['lyrics_body'];
        _isLoading = false;
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
          title: Text(
            "Track Details",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: isNetwork
            ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songDetail['track_name'].toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Artist",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songDetail['artist_name'].toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Album Name",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songDetail['album_name'].toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Explicit",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songDetail['explicit'].toString() == "1"
                                ? "True"
                                : "False"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Rating",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songDetail['track_rating'].toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Lyrics",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(songlyrics.toString()),
                          ],
                        ),
                ),
              )
            : Center(child: Text("No Internet Connection")));
  }
}
