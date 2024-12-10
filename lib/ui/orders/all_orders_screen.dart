import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:rent_and_return/ui/orders/new_orders_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/action_btn.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_search_bar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: CAppbar(
              title: "All Orders",
              leading: false,
              action: [
                actionBtn(() {
                  Get.to(() => CreateOrderUserDetailScreen());
                }, "New Order")
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TabBar(
                dividerColor: Colors.transparent,
                indicatorColor: AppTheme.theme.primaryColor,
                labelColor: AppTheme.theme.primaryColor,
                labelStyle: AppTheme.theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelColor: Colors.black,
                tabs: [
                  SizedBox(
                    width: sW * 0.4,
                    child: const Tab(
                      text: "Active",
                    ),
                  ),
                  SizedBox(
                    width: sW * 0.4,
                    child: const Tab(
                      text: "Closed",
                    ),
                  ),
                ],
              ),
              Spacing.v20,
              const Expanded(
                child: TabBarView(
                  children: [
                    ActiveOrderTab(),
                    ClosedOrderTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveOrderTab extends StatelessWidget {
  const ActiveOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Column(
      children: [
        csearchbar(sW, "Search Item"),
        Spacing.v20,

        ///
        Expanded(
          child: ListView.builder(
              itemCount: 2,
              itemBuilder: (i, context) {
                return card(sW, sH);
              }),
        )
      ],
    );
  }

  Widget card(sW, sH) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        color: AppTheme.theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '₹',
                      style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        // color: AppTheme.theme.primaryColor,
                      ),
                      children: [
                        TextSpan(
                          text: '4300',
                          style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            // color: AppTheme.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/user_image.png",
                    height: sH * 0.15,
                    width: sW * 0.3,
                    fit: BoxFit.fill,
                  ),
                  Spacing.h10,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Praveen Kulkami",
                        style: AppTheme.theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Spacing.v10,
                      cardDetail(Icons.pin_drop, "City Park, Indore"),
                      Spacing.v10,
                      cardDetail(Icons.phone, "9755477792"),
                      Spacing.v10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          cardDetail(Icons.done, "23 Dec, 2024"),
                          SizedBox(
                            width: sW * 0.01,
                          ),
                          const Text(
                            "ID: 2003",
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardDetail(IconData icon, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: AppTheme.theme.primaryColor,
          child: Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
        ),
        Spacing.h10,
        Text(
          label,
          style: AppTheme.theme.textTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            // color: AppTheme.theme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class ClosedOrderTab extends StatelessWidget {
  const ClosedOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
