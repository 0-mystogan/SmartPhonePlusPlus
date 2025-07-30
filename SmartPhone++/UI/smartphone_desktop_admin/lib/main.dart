import 'package:smartphone_desktop_admin/providers/auth_provider.dart';
import 'package:smartphone_desktop_admin/providers/city_provider.dart';
import 'package:smartphone_desktop_admin/providers/service_provider.dart';
import 'package:smartphone_desktop_admin/providers/user_provider.dart';
import 'package:smartphone_desktop_admin/providers/role_provider.dart';
import 'package:smartphone_desktop_admin/providers/product_provider.dart';
import 'package:smartphone_desktop_admin/providers/category_provider.dart';
import 'package:smartphone_desktop_admin/screens/city_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_desktop_admin/utils/text_field_decoration.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<ServiceProvider>(
          create: (context) => ServiceProvider(),
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (context) => RoleProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPhone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB39DDB), // light purple
          primary: Color(0xFF512DA8), // dark purple
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), // solid light gray
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  color: Color.fromARGB(255, 236, 236, 236),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/smartphone_logo.png",
                          height: 150,
                          width: 150,
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: usernameController,
                          decoration: customTextFieldDecoration(
                            "Username",
                            prefixIcon: Icons.account_circle_sharp,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: customTextFieldDecoration(
                            "Password",
                            prefixIcon: Icons.password,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            AuthProvider.username = usernameController.text;
                            AuthProvider.password = passwordController.text;

                            try {
                              print(
                                "Username:  {AuthProvider.username}, Password:  {AuthProvider.password}",
                              );
                              var cityProvider = CityProvider();
                              var cities = await cityProvider.get();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityListScreen(),
                                ),
                              );
                            } on Exception catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Login failed"),
                                  content: Text(
                                    e.toString().replaceFirst('Exception: ', ''),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              print(e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                            ), // Button padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ), // Rounded corners
                            ),
                            minimumSize: Size(double.infinity, 30),
                          ),
                          child: Text("Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Footer (centered at the bottom)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                '© 2025 SmartPhone++',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
