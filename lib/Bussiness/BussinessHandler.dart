class BussinessHandler {
  static const double BEAN_RATE = 1000; // 1k VND = 1 bean
  static const int PRICE_QUANTITY = 10;

  static int beanReward(double total) {
    return (total / BEAN_RATE).round();
  }

  static double countPrice(List<double> prices, int quantity,
      [double weight = 1]) {
    double total = 0;

    for(int i = 0; i < quantity; i++){
      if(i >= PRICE_QUANTITY){
        total += prices[PRICE_QUANTITY - 1];
      }
      else total += prices[i];
    }

    print("total: " + total.toString());

    return total;
  }
}
