import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {
      "month": "October",
      "totalOrders": "100",
      "closedOrders": "80",
      "pendingOrders": "20",
      "revenue": "43200/-",
    },
    {
      "month": "November",
      "totalOrders": "120",
      "closedOrders": "100",
      "pendingOrders": "20",
      "revenue": "50000/-",
    },
    {
      "month": "December",
      "totalOrders": "90",
      "closedOrders": "70",
      "pendingOrders": "20",
      "revenue": "40000/-",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Card Example'),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 3),
          ),
          items: data.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Card(
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/calender.png",
                          height: 60,
                          width: 60,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cardTile(item["month"], 15, FontWeight.w600),
                            cardTile("Total Orders: ${item["totalOrders"]}", 13,
                                FontWeight.w400),
                            cardTile("Closed Order: ${item["closedOrders"]}", 13,
                                FontWeight.w400),
                            cardTile("Pending Order: ${item["pendingOrders"]}",
                                13, FontWeight.w400),
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: cardTile(item["revenue"], 14, FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                child: Text(
                                  "Details",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget cardTile(String text, double fontSize, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    );
  }
}
