import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<homePage> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      title: new Text(
        '¡BIENVENIDO!',
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            color: Colors.blueAccent),
      ),
      photoSize: 200.0,
      seconds: 10,
      backgroundColor: Colors.white,
      image: Image.network(
        "https://i.pinimg.com/originals/bd/bc/70/bdbc704c9f6bf2a30b0f32aff6b42830.png",
      ),
      navigateAfterSeconds: new AfterSplash(),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false, //BANER DE DEPURACION
      theme:
      ThemeData(brightness: Brightness.light, primarySwatch: Colors.cyan),
      darkTheme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.blueGrey),
      home: homePage1(),
    );
  }
}

//ESTA CLASE PERMITE REALIZAR CAMBIOS
class homePage1 extends StatefulWidget {
  @override
  _myHomePageState createState() => new _myHomePageState();
}

class _myHomePageState extends State<homePage1> {
  //Metodo asincrono para lectura de json
  Future<String> _loadAsset() async {
    return await rootBundle.loadString(
        'json_assets/person.json');
  }

  Future<List<heroes>> _getHeroes() async {
    String jsonString = await _loadAsset();
    var jsonData = json.decode(jsonString);
    print(jsonData.toString());

    List<heroes> heros = [];
    for (var h in jsonData) {
      heroes he = heroes(
          h["nombre"],
          h["edad"],
          h["altura"],
          h["genero"],
          h["profile"],
          h["identidad"],
          h["descripcion"]);
      heros.add(he);
    }
    print("Numero de elementos");
    print(heros.length);
    return heros;
  }

  AudioPlayer audioPlayer;
  AudioCache audioCache;

  final audioname = "avengers.mp3";

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioCache = AudioCache();

    setState(() {
      audioCache.play(audioname);
    });
  }

  String searchbusqueda = "";
  bool _isSearching = false;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: _isSearching
              ? TextField(
            onChanged: (value) {
              setState(() {
                searchbusqueda = value;
              });
            },
            controller: searchController,
          )
              : Text("Los mejores Superheroes"),
          actions: <Widget>[
            !_isSearching
                ? IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  searchbusqueda = "";
                  this._isSearching = !this._isSearching;
                });
              },
            )
                : IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  this._isSearching = !this._isSearching;
                });
              },
            )
          ],
        ),
        body: Container(
            child: FutureBuilder(
              future: _getHeroes(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(
                      child: Center(
                        child: Text("Loading..."),
                      ));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return snapshot.data[index].nombre.contains(searchbusqueda)
                            ? ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(snapshot
                                  .data[index].profile
                                  .toString())),
                          title: new Text(
                              snapshot.data[index].nombre.toString()),
                          subtitle:
                          new Text(snapshot.data[index].edad.toString()),
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(snapshot.data[index])));
                          },
                        )
                            : Container();
                      });
                }
              },
            )));
  }
}

class heroes {
  final String nombre;
  final String edad;
  final String altura;
  final String genero;
  final String profile;
  final String identidad;
  final String descripcion;

  heroes(this.nombre, this.edad, this.altura, this.genero, this.profile,
      this.identidad, this.descripcion);
}

class DetailPage extends StatelessWidget {
  final heroes hero;

  DetailPage(this.hero);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(hero.nombre.toString())),
      body: Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          //PARA QUE REGResar
          reverse: false,

          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Hero(
                      tag: hero.profile,
                      child: Container(
                        height: 300.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(hero.profile), fit: BoxFit.cover),
                        ),
                      )),
                ),
                new Padding(padding: EdgeInsets.all(20.0)),
                new Text("Nombre:  ${hero.nombre}",
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                new Text("Identidad Secreta:  ${hero.identidad} ",
                    style:
                    TextStyle(fontSize: 15.0)),
                new Text("Edad:  ${hero.edad}",
                    style:
                    TextStyle(fontSize: 15.0)),
                new Text("Altura:  ${hero.altura}",
                    style:
                    TextStyle(fontSize: 15.0)),
                new Text("Genero:  ${hero.genero}",
                    style:
                    TextStyle(fontSize: 15.0)),
                new Text("Descripcion:  ${hero.descripcion}",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white)),
              ]),
        ),

      ),
    );
  }
}