import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key, required this.packages});
  final List<Package> packages;

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool isSwitched = false;
  int selectedProduct = 0;
  final loading = ValueNotifier(false);
  late final Future<CustomerInfo> restorePurchasesFuture;
  List<Package> packages = [];
  Offering? offering;
  dynamic offerings;
  String _getTodayDateString() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }


  @override
  void initState() {
    fetchOffers();
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

  Future<void> fetchOffers() async {
    offerings = await Purchases.getOfferings();
  }

  List<String> images = [
    'assets/pricingimages/11.png',
    'assets/pricingimages/12.png',
    'assets/pricingimages/13.png',
    // 'assets/pricingimages/14.png',
    'assets/pricingimages/15.png',
    'assets/pricingimages/16.png',
    'assets/pricingimages/17.png',
  ];
  List<String> noAIimages = [
    'assets/pricingimages/14.png',
    'assets/pricingimages/11.png',
    // 'assets/pricingimages/high-resolution-icon-18small.jpg',
    'assets/pricingimages/15.png',
    'assets/pricingimages/16.png',
    'assets/pricingimages/17.png',
  ];
  List<String> noAItexts = [
    'Send unlimited live snaps',
    'Increase snapchat score',
    // 'Send 4k videos',
    'No watermarks!',
    'Remove ads',
    'First 3 days free',
  ];
  List<String> texts = [
    'Unlimited AI geneterating with different models',
    'access to ai-tool Up-scale 2 times/day',
    'Send unlimited live snaps',
    // 'Faster image processing',
    'No watermarks!',
    'Remove ads',
    'First 3 days free',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pricingimages/background.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pricingimages/whitesheet.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 65,
              horizontal: 20,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: const Icon(Icons.close),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Snaplet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Column(
                  children: [
                    Text(
                      'Upgrade to access all Pro features',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Scrollbar(
                      thumbVisibility:true,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'How your free trial works:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Starting from today Trial period for 3 days ${packageToString(!isSwitched ? widget.packages[selectedProduct] : packages[selectedProduct])} Starting from ${_getTodayDateString()} You can pay at any time on the Google Play subscriptions page.No charges will be made if you cancel the subscription before the end of the trial period, and a reminder will be sent to you two days before the trial ends.',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(isSwitched ? noAItexts.length : texts.length,
                    (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          isSwitched ? noAIimages[index] : images[index],
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isSwitched ? noAItexts[index] : texts[index],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Or just live Snaps without ads: ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Switch(
                        value: isSwitched,
                        onChanged: (value){
                          setState(() {
                            isSwitched = !isSwitched;
                          });
                          if (isSwitched) {
      offering = offerings.getOffering("premium_subscription_group");
    } else {
      offering = offerings.getOffering("pro AI");
    }
    setState(() {
      packages = offering!.availablePackages;
    });
                        }),
                  ],
                ),
                const SizedBox(
                  height: 170,
                )
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (InAppPurchase.isPro || InAppPurchase.isProAI)
                  TextButton(
                    onPressed: () async {
                      final refundStatus = await InAppPurchase.refund();
                      if (kDebugMode) {
                        print(refundStatus);
                      }
                    },
                    child: const Text('Restore Purchase'),
                  ),
                for (var (index, package) in packages.isEmpty && !isSwitched
                    ? widget.packages.indexed
                    : packages.indexed)
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
                          width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedProduct = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3 days free trial, Auto-renewable',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: packageToString(package),
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                                height: 1.2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedProduct == index)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Colors.black,
                                  )
                                else
                                  const SizedBox.shrink()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(4),
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
                              if (packages.isEmpty && !isSwitched) {
                                InAppPurchase.buyPackage(
                                        widget.packages[selectedProduct])
                                    .then((value) {
                                  loading.value = false;
                                  Navigator.of(context).pop();
                                });
                              } else {
                                InAppPurchase.buyPackage(
                                        packages[selectedProduct])
                                    .then((value) {
                                  loading.value = false;
                                  Navigator.of(context).pop();
                                });
                              }
                            }
                          },
                          child: Center(
                            child: FutureBuilder<CustomerInfo>(
                                future: restorePurchasesFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      value) {
                                    return const CircularProgressIndicator
                                        .adaptive();
                                  }
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot
                                                    .data
                                                    ?.allPurchasedProductIdentifiers
                                                    .isEmpty ??
                                                true
                                            ? 'Start 3 Days Free Trial'
                                            : 'Upgrade Now',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                          'then, ${packageToString(!isSwitched ? widget.packages[selectedProduct] : packages[selectedProduct])}')
                                    ],
                                  );
                                }),
                          ),
                        );
                      }),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Terms of Service',
                      mouseCursor: WidgetStateMouseCursor.clickable,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrlString(termsAndConditionsUrl);
                        },
                      style: const TextStyle(
                        color: Colors.black,
                      )),
                  const TextSpan(
                    text: ' And ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextSpan(
                      text: 'Privacy Policy',
                      mouseCursor: WidgetStateMouseCursor.clickable,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrlString(privacypolicyurl);
                        },
                      style: const TextStyle(
                        color: Colors.black,
                      ))
                ])),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
