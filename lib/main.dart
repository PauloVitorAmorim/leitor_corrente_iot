import 'package:flutter/material.dart';
import 'package:leitor_corrente_iot/calculate_cost.dart';
import 'get_aws_data.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool getParams = false;

  InstantPower actualPower = InstantPower(
    0, 
    dateHour: '', 
    bateria: 0);
  
  TotalPower totalPower = TotalPower(0);

  CalculateParams costParams = CalculateParams(
    acresBandeira: 0, 
    te: 0,
    tsdu: 0,
    bandeira: bandeiraConsumo.verde
  );

  void _incrementCounter() async{
    aws_data data =  aws_data();
    //var _actualPower = data.getActualPower();
    actualPower = await data.getActualPower();
    totalPower = await data.getTotalPower('11_2022');
    if(!getParams){
      costParams = await data.getParameters();    
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {

    InstantPower _instantPower = InstantPower(
      actualPower.current, 
      dateHour: actualPower.dateHour, 
      bateria: actualPower.bateria);

    CalcStats _calcStats = CalcStats(
      actualCostkWh: 5.22, 
      beginPeak: 19,
      endPeak: 23,
      peakCorrection: 1.55, 
      bandeira: bandeiraConsumo.verde);

    

    CalculateCost cost = CalculateCost(
      current: _instantPower, 
      calcStats: _calcStats,
      params: costParams,
    );
    
    CalculateCost totalCost = CalculateCost(
      current: _instantPower, 
      calcStats: _calcStats,
      params: costParams
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(         
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row( 
                    children:[
                      const Icon(Icons.battery_charging_full, size: 30),
                      Text(actualPower.bateria.toString() + ' %'),
                    ]
                  ),
                  const Icon(Icons.flag, color: Colors.green, size: 30),
                ],
              )
            ),
                         
            Expanded(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child:const Text(    
                    'Energia em tempo real',
                    style: TextStyle(
                      fontSize: 42, 
                      fontWeight: FontWeight.bold,     
                    ),
                    textAlign: TextAlign.center,
                  ),   
                ),
                Column(
                  children:[                   
                    const Text(
                      'Valor total estimado: ',            
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),                                        
                    ),
                    Text(
                      'R\$: '+
                      totalCost.getMinCost().toStringAsFixed(2)+
                      ' - '+
                      totalCost.getMaxCost().toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),                  
                    ),
                    const Text(
                      'Potencia total estimado: ',            
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),                  
                    ),
                    Text(
                      'kW: '+
                      totalCost.getMinPow().toStringAsFixed(2)+
                      ' - '+
                      totalCost.getMaxPow().toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),                  
                    ),
                  ]
                ),
                
                Column(
                  children:[
                    Text(
                      'Valor estimado instantâneo R\$: '+
                      cost.getMinCost().toStringAsFixed(2)+
                      ' - '+
                      cost.getMaxCost().toStringAsFixed(2),
                      style: const TextStyle( fontSize: 16, ),                  
                    ),
                    Text(
                      'Potência estimada instantânea: ' + 
                      actualPower.getActualMinPower().round().toString()+
                      ' - '+
                      actualPower.getActualMaxPower().round().toString() +
                      ' kWh',
                      style: const TextStyle( fontSize: 16, ),
                    ),                                                                
                  ]
                ),
                
                ElevatedButton.icon(
                  onPressed: () => _incrementCounter(), 
                  icon: const Icon(Icons.circle), 
                  label: const Text('Recarregar')
                ),
              ]
            ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.electrical_services, size: 30),
                      Text(
                        actualPower.current.toString() + ' A',
                      ),   
                    ],  
                  ),
                  Row(
                    children:[
                      const Icon(Icons.calendar_month_outlined, size: 30),
                      Text(actualPower.getDateHour()),
                    ]
                  )
                ],
              ),
            ) 
          ],
        ),
      ),      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
