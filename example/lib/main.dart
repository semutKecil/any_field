import 'package:any_field/any_field.dart';
import 'package:any_field/any_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  final AnyValueController<List<String>> controller2 = AnyValueController([
    "1",
  ]);
  final AnyValueController<Color> colorController = AnyValueController(
    Colors.blue,
  );
  String? errorText = "test";
  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Form(
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
                        AnyFormField<List<String>>(
                          initialValue: [
                            "value1",
                            "value2",
                            "value3",
                            "value4",
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1),
                            ),
                            labelText: "Label Text",
                            errorText: "error text",
                            helperText: "testt 123",
                            prefixIcon: Icon(Icons.ac_unit_sharp),
                            suffixIcon: Icon(Icons.baby_changing_station_sharp),
                          ),
                          // maxHeight: 300,
                          minHeight: 100,
                          onTap: (value) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(content: Text("xxx"));
                              },
                            );
                          },
                          onChanged: (value) {
                            debugPrint(value?.join(","));
                          },
                          onSaved: (newValue) {
                            debugPrint(newValue?.join(","));
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
                        AnyField<Color>(
                          controller: colorController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1),
                            ),
                            labelText: "Color Field",
                            hintText: "select",
                            errorText: "error text",
                            prefixIcon: Icon(Icons.palette),
                          ),
                          onTap: (value) {
                            if (controller.value == null) {
                              controller.value = "test value";
                            } else {
                              controller.value = null;
                            }
                          },
                          displayBuilder: (context, value) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: BoxBorder.all(width: 1, color: value),
                                color: value.withAlpha(80),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  3,
                                  10,
                                  3,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircleAvatar(
                                        backgroundColor: value,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '#${value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                                      style: TextStyle(
                                        color: value,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20),
                        AnyField<List<String>>(
                          controller: controller2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1),
                            ),
                            labelText: "Custom Field",
                            hintText: "select",
                            errorText: errorText,
                            prefixIcon: Icon(Icons.account_box),
                          ),
                          maxHeight: 250,
                          // minHeight: 100,
                          onTap: (value) async {
                            await showDialog(
                              context: context,
                              builder: (context) =>
                                  AlertDialog(content: Text("dialog test")),
                            );
                          },
                          onChanged: (value) {
                            debugPrint(value?.join(","));
                          },
                          displayBuilder: (context, value) {
                            return Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: List.generate(value.length, (index) {
                                return Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    border: BoxBorder.all(
                                      width: 1,
                                      color: Colors.black38,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            if (controller2.value != null) {
                                              controller2.value = List.from(
                                                controller2.value!
                                                  ..removeLast(),
                                              );
                                            }
                                          },
                                          icon: Icon(Icons.close, size: 20),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                        width: 1,
                                        child: VerticalDivider(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(value[index]),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller2.value = List.from(controller2.value ?? [])
                      ..add(((controller2.value ?? []).length + 1).toString());
                    _formKey.currentState?.save();

                    setState(() {
                      if (errorText == null) {
                        errorText = "new error text";
                      } else {
                        errorText = null;
                      }
                    });
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Center(child: Text("save")),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
