import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ListDataX2 extends GetxController {
  RxList<int> numbers = List<int>.from([0, 1, 2, 3]).obs;

  void httpCall() async {
    await Future.delayed(
        Duration(seconds: 1), () => numbers.add(numbers.last + 1));
    //update();
  }

  void reset() {
    numbers[0] = 5;
//  numbers = numbers.sublist(0, 3).toList();
    update();
  }
}

class GetXListviewPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ListDataX2 dx = Get.put(ListDataX2());
    print('Page ** rebuilt');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Obx(
                () => ListView.builder(
                    itemCount: dx.numbers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Number: ${dx.numbers[index]}'),
                      );
                    }),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('Http Request'),
                      onPressed: dx.httpCall,
                    ),
                    TextButton(
                      child: Text('Reset'),
                      onPressed: dx.reset,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
