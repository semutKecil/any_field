import 'package:any_field/any_field.dart';
import 'package:any_field/any_form_field.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final _formKey = GlobalKey<FormState>();
  final AnyValueController<String> controller = AnyValueController("value");
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      AnyFormField<List<String>>(
                        // controller: controller,
                        initialValue: ["value1", "value2", "value3", "value4"],
                        // leftCompensation: 100,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(width: 1),
                          ),
                          labelText: "Label Text",
                          errorText: "error text",
                          prefixIcon: Icon(Icons.ac_unit_sharp),
                          suffixIcon: Icon(Icons.baby_changing_station_sharp),
                        ),
                        maxHeight: 300,
                        onTap: (value) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(content: Text("xxx"));
                            },
                          );
                        },
                        onChanged: (value) {
                          print(value);
                        },
                        onSaved: (newValue) {
                          print(newValue);
                        },
                        displayBuilder: (context, value) {
                          return Wrap(
                            spacing: 5,
                            children: List.generate(value.length, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  border: BoxBorder.all(
                                    width: 1,
                                    color: Colors.black38,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(value[index]),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      AnyField<String>(
                        controller: controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(width: 1),
                          ),
                          labelText: "Color Picker",
                          hintText: "select",
                          errorText: "error text",
                          prefixIcon: Icon(Icons.abc),
                          // prefix: Icon(Icons.palette),
                        ),
                        // leftCompensation: 250,
                        floatingLabelHeightCompensation: 5,
                        maxHeight: 400,
                        onTap: (value) {
                          if (controller.value == null) {
                            controller.value = "waha";
                          } else {
                            controller.value = null;
                          }
                        },
                        onChanged: (value) {
                          print(value);
                        },
                        displayBuilder: (context, value) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              border: BoxBorder.all(
                                width: 1,
                                color: Colors.black26,
                              ),
                            ),

                            width: 100,
                            height: 100,
                            child: Center(child: Text(value)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _formKey.currentState?.save(),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Center(child: Text("Save")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
