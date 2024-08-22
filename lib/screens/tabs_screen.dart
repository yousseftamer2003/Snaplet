import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/home.dart';
import 'package:sfs_editor/screens/ai_tools_screens/ai_tools_screen.dart';
import 'package:sfs_editor/screens/edit_option_screen.dart';
import 'package:sfs_editor/screens/settings_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key,this.isEditor});
  final bool? isEditor;

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int? selectedIndex;
  List<Widget> pages = [];
  bool _isFetchOffersCalled = false;

  @override
  void initState() {
    if(widget.isEditor != null){
      if(widget.isEditor!){
        selectedIndex = 0;
      }
    }else{
      selectedIndex =1;
    }
    pages = [
      const EditOptionScreen(),
      const MyHomePage(),
      const AitoolsScreen(),
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(!(InAppPurchase.isPro || InAppPurchase.isProAI)){
      if (!_isFetchOffersCalled) {
      _isFetchOffersCalled = true;
      Future.delayed(const Duration(seconds: 2)).then((_) {
        InAppPurchase.fetchOffers(context);
      },);
    }
    }
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? darkMoodColor : Colors.white,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
        title: Row(
          children: [
            Image.asset('assets/starryImages/snaplet-logo high small3 edited.png', width: 35),
            const Text('Snaplet', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              InAppPurchase.fetchOffers(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
              foregroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text( InAppPurchase.isPro || InAppPurchase.isProAI? 'Pro' : 'Get Pro!', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen())
              );
            },
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 5),
        ],
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: themeProvider.isDarkMode ? darkMoodColor : Colors.white,
        selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/starryImages/editor.png', width: 50, color: selectedIndex == 0 ? Colors.pink : themeProvider.isDarkMode ? Colors.white : Colors.black),
            label: 'Editor',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(selectedIndex == 1 ? 'assets/starryImages/snaplet-logo high small3 edited.png' : 'assets/starryImages/disabkedhome.png', width: selectedIndex == 1 ? 35 : 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/starryImages/aitools.png', width: 35, color: selectedIndex == 2 ? Colors.pink : themeProvider.isDarkMode ? Colors.white : Colors.black),
            label: 'AI Tools',
          ),
        ],
        currentIndex: selectedIndex ?? 1,
        selectedItemColor: Colors.pink,
        unselectedItemColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
        onTap: onItemTapped,
      ),
    );
  }
}



