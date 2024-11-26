import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

Widget buildSlidingBanner(List<Widget> children) {
  final CarouselController controller = CarouselController();
  int currentIndex = 0;

  return SizedBox(
    height: 200.0,
    child: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1.0,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                items: children.map((child) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // adjust the padding as required
                  child: child,
                )).toList(),
                carouselController: controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children.asMap().entries.map((entry) {
                  int indicatorIndex = entry.key;
                  return Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == indicatorIndex ? green : background.withOpacity(0.5)
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    ),
  );
}