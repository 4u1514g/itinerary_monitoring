import 'package:flutter/material.dart';
import 'package:itinerary_monitoring/itinerary_monitoring.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          SizedBox(width: 56, height: 56, child: Icon(Icons.calendar_today, color: Colors.white))
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).viewPadding.top + 56,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xff033572), Color(0xff93B5E3)])),
            padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            alignment: Alignment.center,
            child: const Text('Danh sách đơn hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn())),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
          height: 46,
          alignment: Alignment.center,
          child: const Text('Tổng quan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }
}
