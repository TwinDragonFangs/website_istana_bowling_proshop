import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  // =========================
  // ACTIONS
  // =========================

  void _openPhone() async {
    final uri = Uri.parse("tel:+62 821-7204-1712");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openLocation() async {
    final uri = Uri.parse(
      "https://maps.app.goo.gl/oBhoshiUho18kxHW8",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openInstagram() async {
    final uri = Uri.parse(
      "https://instagram.com/istanabowlingproshop",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xff111111),
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 35,
      ),
      child: Column(
        children: [
          const Text(
            "ISTANA BOWLING PROSHOP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "Toko perlengkapan bowling lengkap dengan berbagai pilihan ball, shoes, bags, dan accessories berkualitas.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 25),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 30,
            runSpacing: 15,
            children: [
              // ================= PHONE =================
              InkWell(
                onTap: _openPhone,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "+62 821-7204-1712",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ================= LOCATION =================
              InkWell(
                onTap: _openLocation,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Istana Bowling Proshop Palembang",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ================= INSTAGRAM =================
              InkWell(
                onTap: _openInstagram,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.instagram, color: Colors.pinkAccent),
                    SizedBox(width: 8),
                    Text(
                      "@istanabowlingproshop",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Divider(
            color: Colors.white.withOpacity(0.2),
          ),

          const SizedBox(height: 15),

          const Text(
            "© 2026 Istana Bowling Proshop. All Rights Reserved.",
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}