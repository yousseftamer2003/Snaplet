import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/models/aimodels_model.dart';
import 'package:sfs_editor/screens/ai_tools_screens/tools_prompt_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';

class AitoolsScreen extends StatefulWidget {
  const AitoolsScreen({super.key});

  @override
  State<AitoolsScreen> createState() => _AitoolsScreenState();
}

class _AitoolsScreenState extends State<AitoolsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            height: 200.0,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/starryImages/pinterest.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              height: 200.0,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.black.withOpacity(0.4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'showcases AI tools designed to enhance and modify images.',
                    style: GoogleFonts.nunito(
                      fontWeight : FontWeight.w700,
                      color: Colors.white,
                      fontSize:15.sp
                    )
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 17.w,
              ),
              GradientText(
                'Select a tool:',
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                style:  GoogleFonts.nunito(
                      fontWeight : FontWeight.w700,
                      fontSize:19.sp
                    ),
              ),
            ],
          ),
          Expanded(
            child: GridView.count(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                GestureDetector(
                  onTap: () {
                    if(InAppPurchase.isProAI){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ToolsPromptScreen(
                                isUpscale: false,
                                isFixFace: false,
                              )));
                    }else{
                      InAppPurchase.fetchOffers(context);
                    }
                    
                  },
                  child: _buildGridItem('assets/getimgimages/40.png', 'Instruct','offering step-by-step directions in a concise visual format.')),



                GestureDetector(
                    onTap: () {
                    if(InAppPurchase.isProAI){
                    Provider.of<GetIMageServices>(context,listen: false).getAllModels();
                      List<AiModels> allModels = Provider.of<GetIMageServices>(context,listen: false)
                          .allmodels
                          .where((element) =>
                              element.piplines.contains('inpaint')).toList();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ToolsPromptScreen(
                            models: allModels,
                                isUpscale: false,
                                isFixFace: false,
                              )));
                    }else{
                      InAppPurchase.fetchOffers(context);
                    }
                    },
                    child: _buildGridItem(
                        'assets/starryImages/instruct.jpg', 'Inpainting','effortlessly removing elements to perfect your images.')),



                GestureDetector(
                    onTap: () {
                      if(InAppPurchase.isProAI){
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ToolsPromptScreen(
                                isUpscale: true,
                                isFixFace: false,
                              )));
                      }else{
                        InAppPurchase.fetchOffers(context);
                      }
                    },
                    child: _buildGridItem(
                        'assets/starryImages/upscale.jpg', 'Upscale','unlocking new levels of visual quality.')),


                        
                GestureDetector(
                    onTap: () {
                    if(InAppPurchase.isProAI){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ToolsPromptScreen(
                                isUpscale: false,
                                isFixFace: true,
                              )));
                    }else{
                      InAppPurchase.fetchOffers(context);
                    }
                    },
                    child: _buildGridItem(
                        'assets/starryImages/fixfaces.jpg', 'Fix Faces','correcting imperfections for stunning, flawless results.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGridItem(
  String imagePath,
  String title,
  String description,
) {
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            )
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                                fontWeight : FontWeight.w700,
                                color: Colors.white,
                                fontSize:13.sp
                              ),
                  ),
                ],
              ),
              Text(description,style: const TextStyle(fontWeight : FontWeight.w700,color: Colors.white,fontSize: 10),)
            ],
          ),
        ),
      ),
      (!(InAppPurchase.isPro || InAppPurchase.isProAI))? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.grey.withOpacity(0.8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock),
              Text('Pro',style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ) : const SizedBox()
    ],
  );
}

class GradientText extends StatelessWidget {
  const GradientText(this.text,
      {super.key, required this.gradient, this.style});

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
