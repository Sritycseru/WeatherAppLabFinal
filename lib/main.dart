import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';


void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: "Weather App",
      home: splashScreen(),
      // routes: ,

    )
);

class splashScreen extends StatelessWidget {
  const splashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image:AssetImage('images/loser.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("HamroMausam"),
            MaterialButton(
                child: Text("HomeScreen"),
                color:Colors.blue,
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>Home()),
                  );
                })
          ],
        ),
      ),
    );
  }
}



class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var temp,city, description,icon="10d", currently, humidity, windSpeed, lat, lon,feels_like,sunrise,sunset,date;

  TextEditingController textEditingController=TextEditingController();
  //Location added
  void location()async{
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      // lat = position.latitude.toStringAsFixed(2);
      // lon = position.longitude.toStringAsFixed(2);
      lat = position.latitude;
      lon = position.longitude;
    });

  }
  void localWeather() async {

    var response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&units=metric&appid=28f23b4647736c591ab43a6b469818bf")); //api key
    var results = jsonDecode(response.body);
    setState(() {
      this.temp = results['main']['temp'];
      this.city = results['name'];
      this.description = results['weather'][0]['description'];
      this.currently = results['weather'][0]['main'];
      this.humidity = results['main']['humidity'];
      this.windSpeed = results['wind']['speed'];
      feels_like=results['main']['feels_like'];
      icon=results['weather'][0]['icon'];
    });
  }
//Text field
  void getWeather() async {
    var response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=28f23b4647736c591ab43a6b469818bf')); //api key
    var results = jsonDecode(response.body);
    setState(() {
      this.lat = results['coord']['lat'];
      this.lon = results['coord']['lon'];
      this.temp = (results['main']['temp']-273).toStringAsFixed(2);
      this.description = results['weather'][0]['description'];
      this.currently = results['weather'][0]['main'];
      this.humidity = results['main']['humidity'];
      this.windSpeed = results['wind']['speed'];
      feels_like=results['main']['feels_like'];
      icon=results['weather'][0]['icon'];

    });
  }
  void citySearch(){
    setState(() {
      city = textEditingController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    getWeather();
    localWeather();
    location();
    citySearch();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent,
      appBar: AppBar(
        title: Text("Weather app"),
      ),
      body: Column(
        children: <Widget> [
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 60,),
                Row(
                  children:[

                    SizedBox(width: 50),

                    Text("Latitude : ",
                    ),
                    Text(lat.toString(),
                    ),
                    SizedBox(width:100,),
                    Text("Longitude : ",
                    ),
                    Text(lon.toString(),
                    ),
                  ],
                ),
                Text(city.toString(),
                ) ,
                MaterialButton(onPressed: (){
                  localWeather();
                  location();
                },
                  child: Text('location'),
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'city name',
                    ),
                  ),
                ),
                SizedBox(height: 30,
                ),
                MaterialButton(onPressed: (){
                  getWeather();
                  citySearch();
                },
                  child: Text('getWeather'),
                  color: Colors.blue,
                ),
                SizedBox(height: 20,),
                Image.network("http://openweathermap.org/img/wn/${icon}@2x.png",height:100,width: 100,),
                Text(
                  temp!=null? temp.toString()+" °C": "loading",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.thermometer),
                    title: Text("Temperature"),
                    trailing: Text(temp!=null ? temp.toString()+"\u00B0C" : "just wait, loading"),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.cloud),
                    title: Text("Weather"),
                    trailing: Text(description!=null ? description.toString() : "Loading"),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.sun),
                    title: Text("Humidity"),
                    trailing: Text(humidity!=null ? humidity.toString() : "Loading"),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.sun,
                        size:30),
                    title: Text("Feels_like"),
                    trailing: Text(feels_like!=null ? feels_like.toString() : "Loading"),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.wind),
                    title: Text("Wind Speed"),
                    trailing: Text(windSpeed!=null ? windSpeed.toString() : "Loading"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}