// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../auth_utils.dart';
//
//
// class SideBar extends StatefulWidget {
//   const SideBar({Key? key}) : super(key: key);
//
//   @override
//   State<SideBar> createState() => _SideBarState();
// }
//
// class _SideBarState extends State<SideBar> {
//   late bool isAdmin = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: AuthUtils.checkAdminStatus(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator(); // Show loading indicator while checking admin status
//         }
//
//         isAdmin = snapshot.data ?? false;
//
//         return Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               const DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: primaryColor,
//                 ),
//                 child: Center(
//                   child: Row(
//                     children: [
//                       Text(
//                         'AWP Connect V1',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildMenuItem(
//                 context,
//                 Icons.home,
//                 Colors.indigo,
//                 'Home',
//                     () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const Home()),
//                   );
//                 },
//               ),
//               _buildMenuItem(
//                 context,
//                 Icons.bar_chart_sharp,
//                 Colors.blue,
//                 'Analysis',
//                     () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const AnalysisScreen()),
//                   );
//                 },
//               ),
//               _buildMenuItem(
//                 context,
//                 Icons.document_scanner,
//                 Colors.deepPurple,
//                 'Contracts',
//                     () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const ContractScreen()),
//                   );
//                 },
//               ),
//               if (isAdmin)
//                 _buildMenuItem(
//                   context,
//                   Icons.people,
//                   Colors.deepOrange,
//                   'Employees',
//                       () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const EmployeeList()),
//                     );
//                   },
//                 ),
//               _buildMenuItem(
//                 context,
//                 Icons.calendar_month_rounded,
//                 Colors.red,
//                 'Planner',
//                     () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const PlannerScreen()),
//                   );
//                 },
//               ),
//               _buildMenuItem(
//                 context,
//                 Icons.feedback,
//                 Colors.orange,
//                 'Feedback', // Provide appropriate text
//                     () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const FeedbackScreen()),
//                   );
//                 },
//               ),
//               if (isAdmin)
//                 _buildMenuItem(
//                   context,
//                   Icons.feed,
//                   Colors.deepPurpleAccent,
//                   'Responses',
//                       () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ResponsesScreen()),
//                     );
//                   },
//                 ),
//               if (isAdmin)
//                 _buildMenuItem(
//                   context,
//                   Icons.attach_money,
//                   Colors.green, // Corrected color reference
//                   'Fees', // Provide appropriate text
//                       () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const FeesScreen()),
//                     );
//                   },
//                 ),
//               _buildMenuItem(
//                 context,
//                 Icons.logout,
//                 Colors.red, // Corrected color reference
//                 'Logout', // Provide appropriate text
//                     () async {
//                   await FirebaseAuth.instance.signOut();
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const AuthPage()),
//                         (route) => false,
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMenuItem(
//       BuildContext context,
//       IconData icon,
//       Color color,
//       String text,
//       VoidCallback onClick,
//       ) {
//     return Center(
//       child: ListTile(
//         style: ListTileStyle.drawer,
//         leading: Icon(
//           icon,
//           color: color,
//         ),
//         title: Text(
//           text,
//           style: TextStyle(
//             color: color,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         onTap: onClick,
//       ),
//     );
//   }
// }
//
//
// class MenuItem extends StatefulWidget {
//   final IconData icon;
//   final Color color;
//   final String text; // New property for the text
//   final VoidCallback onClick;
//
//   const MenuItem({
//     Key? key,
//     required this.icon,
//     required this.color,
//     required this.text, // Provide the text for the menu item
//     required this.onClick,
//   }) : super(key: key);
//
//   @override
//   State<MenuItem> createState() => _MenuItemState();
// }
//
// class _MenuItemState extends State<MenuItem> {
//   bool isHovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onHover: (event) => setState(() {
//         isHovered = true;
//       }),
//       onExit: (event) => setState(() {
//         isHovered = false;
//       }),
//       child: InkWell(
//         onTap: widget.onClick,
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.4,
//           height: MediaQuery.of(context).size.height * 0.08,
//           decoration: BoxDecoration(
//             color: isHovered ? CupertinoColors.white : Colors.white,
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 widget.icon,
//                 color: widget.color,
//                 size: 20.0,
//               ),
//               const SizedBox(
//                 width: 10,
//               ), // Add some spacing between icon and text
//               Text(
//                 widget.text,
//                 style: TextStyle(
//                   color: widget.color,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }