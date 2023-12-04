library components;

import 'package:flutter/material.dart';

NavigationBar navigationBar(BuildContext context,{String? selected}) {
  return NavigationBar(
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.calendar_view_month), label: 'Calendar'),
        NavigationDestination(icon: Icon(Icons.people), label: 'Patients'),
      ],
      onDestinationSelected: (int index) {
        const namedRoutes = ['/', '/patients'];
        Navigator.popUntil(context, (route) => route.isFirst);
        if(index!=0) Navigator.pushNamed(context, namedRoutes[index]);
      },
      selectedIndex: selected==null?0:1,
  );
}
