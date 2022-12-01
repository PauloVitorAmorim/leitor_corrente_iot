import 'dart:convert';
import 'package:http/http.dart' as http;

enum bandeiraConsumo{
  verde,
  amarela, 
  vermelha
}

class CalcStats{
  late double actualCostkWh;
  late double beginPeak;
  late double endPeak;
  late double peakCorrection;
  late bandeiraConsumo bandeira;

  CalcStats({
    required this.actualCostkWh, 
    required this.beginPeak,
    required this.endPeak,
    required this.peakCorrection,
    required this.bandeira
  });

}

class CalculateParams{
  late double tsdu;
  late double te;
  late double acresBandeira;
  late bandeiraConsumo bandeira;

  CalculateParams({
    required this.te,
    required this.tsdu,
    required this.bandeira,
    required this.acresBandeira
  });

  factory CalculateParams.fromJson(Map<String, dynamic> json){
    return CalculateParams(
      te:double.parse(json['TE'])/10000,
      tsdu:double.parse(json['TSUD'])/10000,
      acresBandeira: double.parse(json['AcrescimoBandeira'])/10000,
      bandeira: 
        json['Bandeira'] == "Verde" ? bandeiraConsumo.verde : 
        json['Bandeira'] == "Amarela" ? bandeiraConsumo.amarela : 
        bandeiraConsumo.vermelha
    );
  }
}

class CurrentRead{
  double current;
  double getCurrent(){
    return current;
  }

  CurrentRead.customConstructor({required this.current});
}

class InstantPower extends CurrentRead{
  int bateria;
  String dateHour;

  InstantPower(double current,{ 
    required this.dateHour,
    required this.bateria
  }) : super.customConstructor(current: current);

  double getActualMaxPower(){
    return current * 116;
  }

  double getActualMinPower(){
    return current * 101;
  }

  String getDateHour(){
    var parts = dateHour.split('U');

    if(parts.length != 2){
      return 'Dado faltando';
    }

    String getDate(){
      var date = parts[0].split('_');
      if(date.length != 3){
        return 'xx/yy/zzzz';
      }
      return date[2] + '/'+ date[1] + '/' + date[0];
    }

    String getHour(){
      return parts[1].replaceAll('_', ':');
    }

    return getHour() + ' ' + getDate();
  }

  factory InstantPower.fromJson(Map<String, dynamic> json){
    return InstantPower(
      double.parse(json['Corrente']) / 100,
      dateHour: json['tempo'],
      bateria: int.parse(json['BateriaPorcentagem'])
    );
  }
}

class TotalPower extends CurrentRead{
  
  TotalPower(double current) : super.customConstructor(current: current);

  factory TotalPower.fromJson(Map<String, dynamic> json){
    return TotalPower(double.parse(json['Corrente']));
  }
}

class aws_data{

  String cleanJSon(String rawJson){
    rawJson = rawJson
      .replaceAll('"{', '{')
      .replaceAll('}"', '}')
      .replaceAll("\\", "");

    var degugJSON1 = jsonDecode(rawJson)['body']
      .toString()
      .replaceAll("payload: {","")
      .replaceFirst("}", "")
      .replaceAll("[", "")
      .replaceAll("]","");

    var filteredString = degugJSON1.replaceAllMapped(RegExp(r'\b\w+\b'), (match) {
      return '"${match.group(0)}"';
    });
    
    return filteredString.replaceAll("\".\"", ".").replaceAll("\"Total\"", "");
  }

  InstantPower treatActualCurrent(String rawJson){
    final decoded = json.decode(cleanJSon(rawJson));
    return InstantPower.fromJson(decoded);
  }

  TotalPower treatTotalCurrent(String rawJson){
    final decoded = json.decode(cleanJSon(rawJson));
    return TotalPower.fromJson(decoded);
  }

  CalculateParams treatParams(String rawJson){
    final decoded = json.decode(cleanJSon(rawJson));
    return CalculateParams.fromJson(decoded);
  }

  Future<String> httpGet(String server, String path, [String params = '', String value = '']) async{
    var url = params != '' ? Uri.https(server, path, {params:value}):Uri.https(server, path,);//, 
    var response = await http.get(url);
    if(response.statusCode == 200){
      return response.body;
    }else{
      return 'Error';
    }
  }

  Future<String> getDataTest(){
    Future<String> pos = httpGet('xxxxxxxxx.execute-api.us-east-1.amazonaws.com', '/beta/consumoatual');
    return pos;
  }

  Future<InstantPower> getActualPower() async{
    String data = await httpGet('xxxxxxxxx.execute-api.us-east-1.amazonaws.com', '/beta/consumoatual');
    var actuaPower = treatActualCurrent(data);
    return actuaPower;
  }

  Future<TotalPower> getTotalPower(String mesAno) async{
    String data = await httpGet('xxxxxxxxxx.execute-api.us-east-1.amazonaws.com', '/teste_total_mensal/consumototalmensal','mes_ano',mesAno);
    await Future.delayed(const Duration(seconds: 2), (){});
    var totalPower = treatTotalCurrent(data);
    return totalPower;
  }

  Future<CalculateParams> getParameters() async {
    String data = await httpGet('xxxxxxxxxsx.execute-api.us-east-1.amazonaws.com','/etapa1/parametros');
    return treatParams(data.replaceAll('\\', ''));
  }
}