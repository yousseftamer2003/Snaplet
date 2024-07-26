// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sfs_editor/core/ads/ads_loader.dart';
import 'package:sfs_editor/screens/pricing_screen.dart';


class InAppPurchase {
  static final InAppPurchase _instance = InAppPurchase._foo();

  InAppPurchase._foo();

  static InAppPurchase get instance => _instance;

  static bool _isPro = false;
  static bool _isProAI = false;

  static bool get isPro => _isPro;
  static bool get isProAI => _isProAI;

  static final Set<EntitlementInfo> _activeEntitlements = {};

  static Set<EntitlementInfo> get activeEntitlements => _activeEntitlements;

  static hasFreeTrial() {
    return _activeEntitlements.any((element) => element.periodType == PeriodType.trial);
  }

  static Future<void> initialize({required String apiKey}) async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);

    await Purchases.configure(configuration);

    await Purchases.enableAdServicesAttributionTokenCollection();

    await restorePurchases();
  }

  static Future<Map<String, IntroEligibility>> proTrialEligibility() {
    return Purchases.checkTrialOrIntroductoryPriceEligibility(["pro", "no_ads"]);
  }

  static void _handleCustomerInfo(CustomerInfo purchase) {
    purchase.entitlements.active.forEach((key, value) {
      if (value.isActive) {
        _activeEntitlements.add(value);
      }

      switch (key) {
          case "pro":
            AdsLoader.stopAds.value = value.isActive;
            _isPro = value.isActive;
            break;
            case "pro AI":
            AdsLoader.stopAds.value = value.isActive;
            _isProAI = value.isActive;
          break;
          default:
        }
    });
  }

  static Future<void> restorePurchases() async {
    try {
      final ci = await Purchases.restorePurchases();

      _handleCustomerInfo(ci);

    } on PlatformException catch (e) {
      debugPrint("Restore Purchases");
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      switch (errorCode) {
        case PurchasesErrorCode.paymentPendingError:
          debugPrint("User cancelled");
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          debugPrint("User not allowed to purchase");
          break;
        case PurchasesErrorCode.missingReceiptFileError:
          debugPrint("Missing receipt file");
          // solution: https://docs.revenuecat.com/docs/ios-troubleshooting#missing-receipt-file-error
          break;
        default:
          debugPrint("Error: ${errorCode.name}");
          break;
      }
    }
  }

  static Future<void> buyPackage(Package package) async {
    try {
      final purchase = await Purchases.purchasePackage(package);

      _handleCustomerInfo(purchase);

    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      switch (errorCode) {
        case PurchasesErrorCode.paymentPendingError:
          debugPrint("User cancelled");
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          debugPrint("User not allowed to purchase");
          break;
        default:
          debugPrint("Error: ${errorCode.name}");
          break;
      }
    } finally { }
  }

  static Future<RefundRequestStatus> refund() async {
    return Purchases.beginRefundRequestForActiveEntitlement();
  }
  static Future<void> fetchOffers(BuildContext context) async {
  try {
    final offerings = await Purchases.getOfferings();

    Offering? offering;
    
      offering = offerings.getOffering("pro AI"); 
    

    if (offering != null && offering.availablePackages.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx)=> PricingScreen(packages: offering!.availablePackages))
      );
    
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No offering found"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error fetching offerings: $e"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
}