// ignore_for_file: file_names, prefer_const_constructors, use_key_in_widget_constructors, dead_code, unused_label, import_of_legacy_library_into_null_safe, avoid_print, prefer_final_fields, override_on_non_overriding_member, unused_field, annotate_overrides, must_be_immutable, non_constant_identifier_names, unused_element, prefer_equal_for_default_values, deprecated_member_use, prefer_const_constructors_in_immutables, unused_local_variable, await_only_futures, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, unused_import, prefer_adjacent_string_concatenation

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proyectofinal001/CreateNote.dart';
import 'package:proyectofinal001/Theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Drawer.dart';
import "Dart:collection";

class FirstScreen extends StatefulWidget {
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  @override
  void initState() {
    super.initState();
    mostrar_datos();
    mostrarNotasDia();
  }

  int indexa = 0;
  changevalue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(()=>indexa++);
    prefs.setInt('value',indexa);
  }

  CalendarFormat format = CalendarFormat.week;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime nowday = DateTime.now();

  String texto = '';
  String name = 'Usuario';


  List<Nota> notas = [];
  List<Nota> notshowNotas = [];
  List<String> nums=[];
  List<String> notdaynums=[];
  List<String> litz = [];

  void addNote() async {
    var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => Import()));
    if (data != null){
      String a = "$focusedDay";
      String b = a.substring(0, 10);
      a = a.substring(17);
      texto = b;
      Nota nota = Nota(data['title'], data['cont'], data['them'],texto);
      setState(()=> notas.add(nota));
      setState(()=> nums.add('$indexa'));
      setState(()=> litz.add('$indexa'));//comentar si no funciona
      guardar_datos(data['title'], data['cont'], data['them'], indexa, texto);
      guardar_lista(litz);
      print('$nums'+'<=guardado en lista boton +');
      changevalue();
      mostrarNotasDia();
      focusedDay = DateTime.now();
      selectedDay = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agenda de "+name)),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNote();
          setState(()=>name);
        },
        child: Icon(Icons.add, color: whitee),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:<Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selectedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekVisible: true,
              onDaySelected: (DateTime selectDay, DateTime focusDay,){
                setState((){
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                  nowday = DateTime.now();
                });
                mostrarNotasDia();

              },
              calendarFormat: format,
              onFormatChanged: (CalendarFormat _format){
                setState((){
                  format = _format;
                });
              },
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: blueCharcoal,
                  shape: BoxShape.circle
                ),
                todayDecoration: BoxDecoration(
                  color: blueSaphire,
                  shape: BoxShape.circle
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
              selectedDayPredicate: (DateTime date){
                return isSameDay(selectedDay, date);
              },

              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 17.5)
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: notas.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index){
                return Dismissible(
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 37),
                    color: Colors.red[800],
                    child: Icon(Icons.delete_sweep_sharp, size: 40.0, color: whitee)
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 37),
                    color: Colors.red[800],
                    child: Icon(Icons.delete_sweep_sharp, size:40.0, color: whitee)
                  ),
                  key: ObjectKey(nums[index]),
                  child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  decoration: BoxDecoration(
                    color: notas[index].color,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color:Colors.black38,
                        offset: Offset(6, 6),
                        blurRadius: 3
                      )
                    ]
                  ),
                  child: Padding(padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Stack(
                      children: <Widget>[
                      Text(notas[index].titulo, style:
                        TextStyle(fontSize: 20,
                        foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = Colors.black
                        )
                      ),
                      Text(notas[index].titulo, style:
                        TextStyle(
                          fontSize: 20,
                          color: notas[index].color
                        )
                      ),
                      ],),
                      SizedBox(height: 15),
                      Text(notas[index].descripcion, style: Theme.of(context).textTheme.subtitle2),
                      SizedBox(height: 15),
                      Text(notas[index].date),
                    ],
                  ))
                  ),
                onDismissed: (direction){
                  setState(() {
                    nums.removeAt(index);
                    notas.removeAt(index);
                    var nList =[...nums, ...notdaynums];
                    nList = LinkedHashSet<String>.from(nList).toList();
                    guardar_lista(nList);
                  });
                },
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider()
            )
      ])));
  }

  mostrar_datos() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    indexa = prefs.getInt('value') ?? 0;

    name = await prefs.getString('nam')??"Usuario";
    setState(()=>name);

    nums = await prefs.getStringList('list')??[];
  }


  Future guardar_datos(String titulo, String contenido, Color color, int inde, String date) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Color colors = color;
    String colorString = colors.toString();
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);

    await prefs.setString('titulo'+'$inde', titulo);
    await prefs.setString('contenido'+'$inde', contenido);
    await prefs.setString('testcolor'+'$inde', valueString);
    await prefs.setInt('intcolor'+'$inde',value);
    await prefs.setString('date'+'$inde',date);

  }

  guardar_lista(List<String> list) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('list', list);
  }

  mostrarNotasDia() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>listn = await prefs.getStringList('list')??[];

    if(notas.isNotEmpty){
      setState(() {
        notas.clear();
        nums.clear();
        notdaynums.clear();//comentar
      });
      for(String j in listn){
      String ti = await prefs.getString('titulo'+j)??"";
      String no = await prefs.getString('contenido'+j)??"";
      String colst = await prefs.getString('testcolor'+j)??"";
      int va = await prefs.getInt('intcolor'+j)??0;
      String da = await prefs.getString('date'+j)??"";

      Color otherColo = Color(va);

      String m = '$selectedDay';
      String n = m.substring(0, 10);

      Nota shnota = Nota(ti, no, otherColo, da);

      if(da == n){
        if(nums.contains(j)){}
        else{
        setState(() {
          notas.add(shnota);
          nums.add(j);
        });
        }
      }
      else{
        if(notdaynums.contains(j)){}
        else{
          setState(() {
            notshowNotas.add(shnota);
            notdaynums.add(j);
          });
        }
      }
      }
    }
    else{
      setState(() {
        notas.clear();
        nums.clear();
        notdaynums.clear();
      });
    for(String j in listn){
      String ti = await prefs.getString('titulo'+j)??"";
      String no = await prefs.getString('contenido'+j)??"";
      String colst = await prefs.getString('testcolor'+j)??"";
      int va = await prefs.getInt('intcolor'+j)??0;
      String da = await prefs.getString('date'+j)??"";

      Color otherColo = Color(va);

      String m = '$selectedDay';
      String n = m.substring(0, 10);

      Nota shnota = Nota(ti, no, otherColo, da);

      if(da == n){
        setState(() {
          notas.add(shnota);
          nums.add(j);
        });
      }
      else{
        if(notdaynums.contains(j)){}
        else{
          setState((){
            notshowNotas.add(shnota);
            notdaynums.add(j);
          });
        }
      }
    }
    }
    nums = LinkedHashSet<String>.from(nums).toList();
    notdaynums = LinkedHashSet<String>.from(notdaynums).toList();
    litz = [...nums,...notdaynums];
    litz= LinkedHashSet<String>.from(litz).toList();
    guardar_lista(litz);
  }

}

class Nota{
  String titulo = "";
  String descripcion = "";
  Color color = Color(0xffF90A0A);
  String date;

  Nota(this.titulo, this.descripcion, this.color, this.date);
}



