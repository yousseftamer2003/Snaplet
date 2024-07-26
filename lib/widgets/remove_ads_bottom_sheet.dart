import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sfs_editor/constants/strings.dart';

class SubscriptionsBottomSheet extends StatefulWidget {
const SubscriptionsBottomSheet({super.key, required this.packages});

  final List<Package> packages;

  @override
  State<SubscriptionsBottomSheet> createState() => SubscriptionsBottomSheetState();
}

class SubscriptionsBottomSheetState extends State<SubscriptionsBottomSheet> {
  int selectedProduct = 0;
  final loading = ValueNotifier(false);
  late final Future<CustomerInfo> restorePurchasesFuture;

  @override
  void initState() {
    restorePurchasesFuture = Purchases.restorePurchases();
    super.initState();
  }

  String packageToString(Package package) {
    return "${package.storeProduct.priceString} / ${packageTypeToString(package.packageType)}";
  }

  String packageTypeToString(PackageType packageType) {
    switch (packageType) {
      case PackageType.lifetime:
        return "Lifetime";
      case PackageType.annual:
        return "Year";
      case PackageType.sixMonth:
        return "Six Month";
      case PackageType.threeMonth:
        return "Three Month";
      case PackageType.twoMonth:
        return "Two Month";
      case PackageType.weekly:
        return "Week";
      case PackageType.monthly:
        return "Month";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Snaplet Premium",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    "Upgrade to access all\nPremium Features",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'No More Ads',
                    '4K video support',
                    'AI photos generation',
                    'AI Tools',
                    'First 3 days Free'
                  ].map((e) => Row(
                      children: [
                        const Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  if(InAppPurchase.isPro)
                    TextButton(
                        onPressed: () async {
                          final refundStatus = await InAppPurchase.refund();
                          if (kDebugMode) {
                            print(refundStatus);
                          }
                        }, 
                        child: const Text('Restore Purchase'),
                      ),
                  for (var (index, package) in widget.packages.indexed)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedProduct == index
                            ? Colors.black
                            : Colors.grey, 
                          width: 1
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedProduct = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: packageToString(package),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          height: 1.2),
                                    ),
                                  ],
                                ),
                              ),
                              if(selectedProduct == index)
                                const Icon(
                                  Icons.check_rounded,
                                  color: Colors.black,
                                )
                              else
                                const SizedBox.shrink()
                            ],
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    child: ValueListenableBuilder(
                      valueListenable: loading,
                      builder: (context, value, child) {
                        return InkWell(
                          onTap: () async {
                            if (!loading.value) {
                              loading.value = true;
                              InAppPurchase.buyPackage(widget.packages[selectedProduct]).then((value) {
                                loading.value = false;
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Center(
                            child: FutureBuilder<CustomerInfo>(
                              future: restorePurchasesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting || value) {
                                  return const CircularProgressIndicator.adaptive();
                                }
                          
                                return Text(
                                  snapshot.data?.allPurchasedProductIdentifiers.isEmpty ?? true ? 'Start 3 Days Free Trial' : 'Upgrade Now',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          mouseCursor: WidgetStateMouseCursor.clickable,
                          recognizer: TapGestureRecognizer()..onTap = () {
                            launchUrlString(termsAndConditionsUrl);
                          },
                          style: const TextStyle(
                            color: Colors.black,
                          )
                        ),
                        const TextSpan(
                          text: ' And ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          mouseCursor: WidgetStateMouseCursor.clickable,
                          recognizer: TapGestureRecognizer()..onTap = () {
                            launchUrlString(privacypolicyurl);
                          },
                          style: const TextStyle(
                            color: Colors.black,
                          )
                        )
                      ]
                    )
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
