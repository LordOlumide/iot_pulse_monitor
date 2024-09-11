import 'package:flutter/material.dart';

class IpAddressContainer extends StatelessWidget {
  final String addr;
  final VoidCallback onTap;

  const IpAddressContainer(
      {super.key, required this.addr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
        ),
        child: Text(
          addr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
