import 'package:leitor_corrente_iot/get_aws_data.dart';

class CalculateCost{
  late CurrentRead current;
  late CalcStats calcStats;
  late CalculateParams params;

  CalculateCost({
    required this.current,
    required this.calcStats,
    required this.params
  });

  double calculateCost(double power) {
    double powerInKiloWatt = power/1000;
    double cost = ((powerInKiloWatt) * params.te);
    cost += ((powerInKiloWatt) * params.tsdu);
    cost += powerInKiloWatt * params.acresBandeira;
    return cost;
  } 

  double getMaxCost() => calculateCost(getMaxPow());
  double getMinCost() => calculateCost(getMinPow());

  double getMaxPow() => current.getCurrent() * 116;
  double getMinPow() => current.getCurrent() * 101;
}