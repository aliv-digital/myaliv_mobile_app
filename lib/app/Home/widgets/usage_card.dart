import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UsageCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String total;
  final String remainingLabel;
  final double progress;
  final Color color;
  final bool isPostpaid;

  const UsageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.remainingLabel,
    required this.progress,
    required this.color,
    required this.isPostpaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124, //height: 124,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // boxShadow: const [
        //   // BoxShadow(
        //   //   color: Colors.black12,
        //   //   blurRadius: 14,
        //   //   offset: Offset(0, 6),
        //   // ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, color: color, height: 18, width: 18),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,overflow:TextOverflow.clip,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          isPostpaid == false
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title == 'data' ? '2.4 GB' : 'unlimited',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: title == 'data' ? ' of\n14 GB' : '\nlocal',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$value of \n',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: total,
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 16),
          Text(
            remainingLabel,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          isPostpaid == false ? _progressBar() : _postpaidprogressBar(),
          const SizedBox(height: 0),
        ],
      ),
    );
  }


  Widget _progressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * progress.clamp(0.0, 1.0);

          Color mainColor = Color(0x3F808080);
          LinearGradient gradient = LinearGradient(
            colors: [const Color(0x00DD3038), const Color(0xFFDD3038)],
          );
          if (progress < 0.35) {
            mainColor = Color(0x26DD3038);
            gradient = LinearGradient(
              colors: [ const Color(0xFFDD3038),const Color(0x00DD3038),],
            );
          } else if (progress < 0.6) {
            mainColor = Color(0x26FFC627);
            gradient = LinearGradient(
              colors: [Color(0x26FFC627),Color(0xFFFFC627), ],
            );
          } else {
            mainColor = Color(0x2617B26A);
            gradient = LinearGradient(
              // colors: [Color(0xFF17B26A), Color(0x2617B26A)],
              colors: [Color(0x2617B26A),Color(0xFF17B26A), ],
            );
          }
          return Stack(
            children: [
              // Background

              Container(height: 6, color: mainColor),

              // Gradient progress (width = percentage)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: width,
                decoration: BoxDecoration(
                    gradient: gradient),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _postpaidprogressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * progress.clamp(0.0, 1.0);

          Color mainColor = Color(0x3F808080);
          LinearGradient gradient = LinearGradient(
            colors: [const Color(0x00DD3038), const Color(0xFFDD3038)],
          );
          if (progress < 0.35) {
            mainColor = Color(0x26DD3038);
            gradient = LinearGradient(
              colors: [ const Color(0xFFDD3038),const Color(0x00DD3038),],
            );
          } else if (progress < 0.6) {
            mainColor = Color(0x26FFC627);
            gradient = LinearGradient(
              colors: [Color(0x26FFC627),Color(0xFFFFC627), ],
            );
          } else {
            mainColor = Color(0x2617B26A);
            gradient = LinearGradient(
              // colors: [Color(0xFF17B26A), Color(0x2617B26A)],
              colors: [Color(0x2617B26A),Color(0xFF17B26A), ],
            );
          }

          return Stack(
            children: [
              // Background
              Container(height: 6, color: mainColor),

              // Gradient progress (width = percentage)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: gradient),
              ),
            ],
          );
        },
      ),
    );
  }
}
